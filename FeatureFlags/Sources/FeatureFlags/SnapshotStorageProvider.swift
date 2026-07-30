import Foundation
import UnleashProxyClientSwift

/// Toggle storage that can be enumerated, not just queried by key.
///
/// The SDK's own `DictionaryStorageProvider` keeps its dictionary private and only exposes
/// `value(key:)`, so there is no way to list what Unleash returned — which is exactly what building
/// the `X-Feature-Flags` header needs. `StorageProvider` is the injection point the SDK provides for
/// this; the provider is handed to a `Poller`, which is handed to the client.
final class SnapshotStorageProvider: StorageProvider {
    private var storage: [String: Toggle] = [:]
    private let lock = NSLock()

    func set(values: [String: Toggle]) {
        lock.lock()
        defer { lock.unlock() }
        storage = values
    }

    func value(key: String) -> Toggle? {
        lock.lock()
        defer { lock.unlock() }
        return storage[key]
    }

    func clear() {
        lock.lock()
        defer { lock.unlock() }
        storage = [:]
    }

    /// Every toggle Unleash last returned, including disabled ones.
    var toggles: [Toggle] {
        lock.lock()
        defer { lock.unlock() }
        return Array(storage.values)
    }
}
