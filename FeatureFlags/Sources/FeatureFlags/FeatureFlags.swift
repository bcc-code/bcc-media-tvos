import Combine
import Foundation
import UnleashProxyClientSwift

/// Unleash feature flags.
///
/// The flags are consumed in two ways: locally via ``has(_:)`` / ``variant(_:)``, and by forwarding
/// the resolved set to the API in the `X-Feature-Flags` header via ``headerValue`` so the backend
/// evaluates the same flags we did.
public final class FeatureFlagsClient: ObservableObject {
    public static let shared = FeatureFlagsClient()

    /// Every toggle Unleash last returned. Published so SwiftUI can react to flag changes.
    ///
    /// Prefer ``headerValue`` / ``has(_:)`` for reads that must not lag — this is updated via a hop
    /// to the main queue, those read the underlying storage directly.
    @Published public private(set) var toggles: [Toggle] = []

    private let storage = SnapshotStorageProvider()
    private let lock = NSLock()
    /// Readable internally so tests can assert that repeated `setup` calls reuse one instance.
    private(set) var client: UnleashClient?
    private var currentContext: [String: String]?

    init() {}

    /// Starts Unleash, or reconfigures it if the context changed.
    ///
    /// Safe to call repeatedly: `ContentView.load()` runs on launch, on every foreground and on auth
    /// changes. Creating a fresh client per call used to orphan the previous one, leaving its poll
    /// and metrics timers running for the rest of the process's life.
    ///
    /// A missing or malformed URL/key disables flags instead of failing: the SDK calls `fatalError`
    /// on a URL without a scheme, and `CI.swift` ships the literal `"$UNLEASH_URL"` placeholder that
    /// `envsubst` turns into an empty string when the secret isn't attached.
    public func setup(unleashUrl: String, clientKey: String, context: [String: String]) {
        guard let url = URL(string: unleashUrl), url.scheme != nil else {
            Self.log("disabled — no usable url (got \(unleashUrl.debugDescription))")
            return
        }
        guard !clientKey.isEmpty else {
            Self.log("disabled — no client key (url \(url.absoluteString))")
            return
        }

        lock.lock()
        if let existing = client {
            guard currentContext != context else {
                lock.unlock()
                Self.debug("setup skipped, context unchanged")
                return
            }
            currentContext = context
            lock.unlock()
            Self.log("context changed, refetching\(Self.describe(context))")
            // Restarts polling on the same instance, so nothing is orphaned.
            existing.updateContext(context: context, completionHandler: Self.logPollerError)
            return
        }

        let client = makeClient(url: url, clientKey: clientKey, context: context)
        self.client = client
        currentContext = context
        lock.unlock()

        Self.log("starting — \(url.absoluteString), polling every \(Self.refreshInterval)s\(Self.describe(context))")
        client.subscribe(.ready) { [weak self] in self?.refreshToggles() }
        client.subscribe(.update) { [weak self] in self?.refreshToggles() }
        // `verbose` also turns on the SDK's own per-poll messages, which is the only way to see
        // failures after the first fetch — the timer-driven polls take no completion handler.
        client.start(Self.verbose, completionHandler: Self.logPollerError)
    }

    /// Value for the `X-Feature-Flags` request header, or `nil` when no flags are enabled or Unleash
    /// hasn't answered yet — in which case the header is omitted rather than sent empty.
    public var headerValue: String? {
        Self.headerValue(for: storage.toggles)
    }

    public func has(_ key: String) -> Bool {
        currentClient?.isEnabled(name: key) == true
    }

    /// The payload of `key`'s variant, if the flag and its variant are both enabled.
    ///
    /// Note this is the variant *payload*, not the variant *name* that goes into the header.
    public func variant(_ key: String) -> String? {
        guard let variant = currentClient?.getVariant(name: key), variant.enabled else {
            return nil
        }
        return variant.payload?.value
    }

    // MARK: - Header formatting

    /// Formats toggles as `key` / `key:variantName`, comma separated and sorted by key.
    ///
    /// The backend reads a key's mere presence as "enabled" (`utils.FeatureFlags.Has`), so disabled
    /// toggles must never be emitted. A toggle with no usable variant is sent bare. Sorting keeps the
    /// value stable across polls for the same flag set.
    static func headerValue(for toggles: [Toggle]) -> String? {
        let entries = toggles
            .filter { $0.enabled && isHeaderSafe($0.name) }
            .sorted { $0.name < $1.name }
            .map { toggle -> String in
                guard let variant = toggle.variant,
                      variant.enabled,
                      isHeaderSafe(variant.name)
                else {
                    return toggle.name
                }
                return "\(toggle.name):\(variant.name)"
            }

        return entries.isEmpty ? nil : entries.joined(separator: ",")
    }

    /// Printable ASCII with no separator characters, so a name can't break the header's own syntax.
    private static func isHeaderSafe(_ value: String) -> Bool {
        guard !value.isEmpty else { return false }
        return value.unicodeScalars.allSatisfy { scalar in
            (0x21 ... 0x7E).contains(scalar.value) && scalar != "," && scalar != ":"
        }
    }

    // MARK: - Private

    private var currentClient: UnleashClient? {
        lock.lock()
        defer { lock.unlock() }
        return client
    }

    private func makeClient(url: URL, clientKey: String, context: [String: String]) -> UnleashClient {
        let appName = "bccm-tvos"
        let poller = Poller(
            refreshInterval: Self.refreshInterval,
            unleashUrl: url,
            apiKey: clientKey,
            storageProvider: storage,
            appName: appName,
            connectionId: UUID()
        )
        return UnleashClient(
            unleashUrl: url.absoluteString,
            clientKey: clientKey,
            refreshInterval: Self.refreshInterval,
            appName: appName,
            context: context,
            poller: poller
        )
    }

    private func refreshToggles() {
        let snapshot = storage.toggles
        let enabled = snapshot.filter { $0.enabled }
        Self.log("\(enabled.count) enabled of \(snapshot.count) — X-Feature-Flags: \(headerValue ?? "<omitted>")")
        if Self.verbose, !snapshot.isEmpty {
            for toggle in snapshot.sorted(by: { $0.name < $1.name }) {
                let variant = toggle.variant.map { " variant=\($0.name) enabled=\($0.enabled) payload=\($0.payload?.value ?? "-")" } ?? ""
                Self.debug("  \(toggle.name) enabled=\(toggle.enabled)\(variant)")
            }
        }

        if Thread.isMainThread {
            toggles = snapshot
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.toggles = snapshot
            }
        }
    }

    private static let refreshInterval = 60

    private static func logPollerError(_ error: PollerError?) {
        if let error {
            log("fetch failed: \(error)")
        }
    }

    // MARK: - Logging

    /// Set `UNLEASH_DEBUG=1` in the scheme for per-toggle detail and the SDK's own poll messages.
    static let verbose = ProcessInfo.processInfo.environment["UNLEASH_DEBUG"] == "1"

    private static func log(_ message: String) {
        print("[Unleash] \(message)")
    }

    private static func debug(_ message: String) {
        if verbose {
            log(message)
        }
    }

    /// Context is only spelled out in verbose mode — it carries userId / anonymousId.
    private static func describe(_ context: [String: String]) -> String {
        if verbose {
            let pairs = context.sorted { $0.key < $1.key }.map { "\($0.key)=\($0.value)" }
            return "\n[Unleash]   context: \(pairs.joined(separator: " "))"
        }
        return " (context keys: \(context.keys.sorted().joined(separator: ", ")))"
    }
}
