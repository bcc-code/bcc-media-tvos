
import Auth0
import Foundation
import SimpleKeychain

/// A class rather than a struct because it owns mutable state that outlives any one call —
/// `errorHandler` is registered from the UI and read from whichever thread a failing request lands
/// on. As a struct it could only mutate that state by smuggling it through a reference type, which
/// is exactly what the `Callbacks` box used to do.
public final class Provider {
    public var logger: (Error) -> Void = { error in
        print(error)
    }
    
    public init(serviceName: String, accessGroup: String, logger: @escaping (Error) -> Void) {
        self.logger = logger
        self.options = Provider.getConfigFromPlist() ?? Options(client_id: "", scope: "", audience: "", domain: "")
        self.credentialsManager = Auth0.CredentialsManager(authentication: authentication(), storage: SimpleKeychain(service: serviceName, accessGroup: accessGroup))
    }
    
    internal var options: Options
    internal var credentialsManager: Auth0.CredentialsManager
    
    internal struct Options {
        var client_id: String
        var scope: String
        var audience: String
        var domain: String
    }
    
    private static func getConfigFromPlist() -> Options? {
        // Returning nil rather than trapping also makes `Provider` constructible in a SwiftPM test
        // bundle, where `Bundle.main` is the test runner and has no Auth0.plist.
        guard let path = Bundle.main.path(forResource: "Auth0", ofType: "plist") else {
            return nil
        }
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            return nil
        }
        guard let plist = try? PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil) as? [String: String] else {
            return nil
        }
        guard let clientId = plist["ClientId"] else {
            return nil
        }
        guard let domain = plist["Domain"] else {
            return nil
        }
        return Options(client_id: clientId, scope: "openid profile email offline_access country church", audience: "api.bcc.no", domain: domain)
    }

    public func isAuthenticated() -> Bool {
        credentialsManager.hasValid() || credentialsManager.canRenew()
    }
    
    /// Guards `errorHandler`: it is registered from the main actor, but read on whichever thread a
    /// failing request happens to be on. Same idiom as `FeatureFlagsClient`.
    private let lock = NSLock()
    private var errorHandler: (() -> Void)?

    /// Registers the handler invoked when the access token cannot be produced, **replacing** any
    /// previous one.
    ///
    /// It replaces rather than accumulates because `ContentView.load()` registers on launch, on every
    /// foreground and after every auth change. Appending meant one token failure fanned out into one
    /// sign-in flow per foreground since launch — each of which revokes credentials first.
    public func registerErrorCallback(_ cb: @escaping () -> Void) {
        lock.lock()
        defer { lock.unlock() }
        errorHandler = cb
    }

    public func getAccessToken() async -> String? {
        do {
            if isAuthenticated() {
                return try await credentialsManager.credentials().accessToken
            }
        } catch {
            logger(error)

            // Only hand off when the session is really gone. The handler revokes credentials and
            // starts a fresh sign-in, so treating a network blip as fatal signed the user out.
            guard Provider.requiresReauthentication(error) else {
                return nil
            }

            // Copied out and the lock released before calling: the handler re-enters app code, which
            // is free to register a new one.
            lock.lock()
            let handler = errorHandler
            lock.unlock()
            handler?()
        }
        return nil
    }

    /// Whether failing to produce an access token means the session is genuinely gone, as opposed to
    /// something worth retrying.
    ///
    /// Deliberately biased towards retrying. The registered handler revokes the stored credentials and
    /// starts a new sign-in, so misreading a transient failure costs the user their session, while
    /// misreading a permanent one only costs one more failed request.
    ///
    /// Internal rather than private so the tests can reach it.
    static func requiresReauthentication(_ error: Error) -> Bool {
        guard let error = error as? CredentialsManagerError else {
            return false
        }

        // Nothing to renew from, so a new sign-in is the only way forward. Auth0 documents both of
        // these as carrying no cause, which is what makes `==` usable here: that operator compares
        // `localizedDescription` as well as the code, and the description embeds the cause. So
        // `error == .renewFailed` would never match a real renewal failure — hence the cause-based
        // check below instead of comparing against `.renewFailed`.
        if error == .noCredentials || error == .noRefreshToken {
            return true
        }

        return renewalIsUnrecoverable(error.cause)
    }

    /// Split out from ``requiresReauthentication(_:)`` so it can be tested directly:
    /// `CredentialsManagerError`'s initialiser is internal to Auth0, so a `renewFailed` carrying a
    /// cause cannot be constructed outside that module.
    static func renewalIsUnrecoverable(_ cause: Error?) -> Bool {
        guard let cause = cause as? AuthenticationError else {
            return false
        }

        // Never reached Auth0 — offline, DNS failure, timeout. The refresh token is very likely fine.
        if cause.isNetworkError {
            return false
        }

        // `invalid_grant` is the OAuth code for a refresh token that has been revoked, expired or
        // otherwise refused, and `login_required` says so outright. Anything else — 5xx, rate
        // limiting, an unrecognised code — is treated as retryable.
        return cause.code == "invalid_grant" || cause.isLoginRequired
    }
    
    public func logout() async -> Bool {
        do {
            try await credentialsManager.revoke()
        } catch {
            print(error)
            _ = credentialsManager.clear()
        }
        return true
    }
}
