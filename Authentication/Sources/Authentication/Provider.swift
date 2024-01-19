
import Auth0
import SimpleKeychain
import Foundation

class Callbacks {
    var callbacks: [() -> Void] = []
    
    func append(_ cb: @escaping () -> Void) {
        callbacks.append(cb)
    }
}

public struct Provider {
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
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: "Auth0", ofType: "plist")!)
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        guard let plist = try? PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil) as? [String:String] else {
            return nil
        }
        guard let clientId = plist["ClientId"] else {
            return nil
        }
        guard let domain = plist["Domain"] else {
            return nil
        }
        return Options(client_id: clientId, scope: "openid profile email offline_access", audience: "api.bcc.no", domain: domain)
    }

    private enum AuthenticationError: Error {
        case emptyResponse
    }

    public func isAuthenticated() -> Bool {
        credentialsManager.hasValid() || credentialsManager.canRenew()
    }
    
    private var logoutCallbacks = Callbacks()
    
    public func registerLogoutCallback(_ cb: @escaping () -> Void) {
        self.logoutCallbacks.append(cb)
    }
    
    private var errorCallbacks = Callbacks()
    
    public func registerErrorCallback(_ cb: @escaping () -> Void) {
        self.errorCallbacks.append(cb)
    }

    public func getAccessToken() async -> String? {
        do {
            if isAuthenticated() {
                return try await credentialsManager.credentials().accessToken
            }
        } catch {
            self.logger(error)
            
            for cb in errorCallbacks.callbacks {
                cb()
            }
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
        for cb in logoutCallbacks.callbacks {
            cb()
        }
        return true
    }
}
