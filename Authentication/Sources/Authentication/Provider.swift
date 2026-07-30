
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

    private enum AuthenticationError: Error {
        case emptyResponse
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

            // Copied out and the lock released before calling: the handler re-enters app code, which
            // is free to register a new one.
            lock.lock()
            let handler = errorHandler
            lock.unlock()
            handler?()
        }
        return nil
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
