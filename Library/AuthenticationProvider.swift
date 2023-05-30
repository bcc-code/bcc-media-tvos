//
// Created by Fredrik Vedvik on 09/03/2023.
//

import Auth0
import SimpleKeychain
import Foundation

private struct TokenRequestBody: Codable {
    var clientId: String
    var scope: String
    var audience: String

    enum CodingKeys: String, CodingKey {
        case clientId = "client_id"
        case scope = "scope"
        case audience = "audience"
    }
}

private struct GetTokenRequest: Codable {
    var grantType = "urn:ietf:params:oauth:grant-type:device_code"
    var deviceCode: String
    var clientId: String

    enum CodingKeys: String, CodingKey {
        case grantType = "grant_type"
        case deviceCode = "device_code"
        case clientId = "client_id"
    }
}

private struct FailedTokenRetrieval: Codable {
    var error: String
    var error_description: String
}

struct DeviceTokenRequestResponse: Codable {
    var deviceCode: String
    var userCode: String
    var verificationUri: String
    var expiresIn: Int
    var interval: Double
    var verificationUriComplete: String

    enum CodingKeys: String, CodingKey {
        case deviceCode = "device_code"
        case userCode = "user_code"
        case verificationUri = "verification_uri"
        case expiresIn = "expires_in"
        case interval = "interval"
        case verificationUriComplete = "verification_uri_complete"
    }
}

class ErrorCallbacks {
    var callbacks: [() -> Void] = []
    
    func append(_ cb: @escaping () -> Void) {
        callbacks.append(cb)
    }
}

struct AuthenticationProvider {
    public var logger: (Error) -> Void = { error in
        print(error)
    }
    
    init(logger: @escaping (Error) -> Void) {
        self.logger = logger
    }
    
    private var options = AuthenticationProvider.getConfigFromPlist() ?? Options(client_id: "", scope: "", audience: "", domain: "")
    private var credentialsManager = Auth0.CredentialsManager(authentication: authentication(), storage: SimpleKeychain(service: "bcc.media", accessGroup: "group.tv.brunstad.app"))
    
    private struct Options {
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

    func isAuthenticated() -> Bool {
        credentialsManager.hasValid() || credentialsManager.canRenew()
    }
    
    private var errorCallbacks = ErrorCallbacks()
    
    func registerErrorCallback(_ cb: @escaping () -> Void) {
        self.errorCallbacks.append(cb)
    }

    func getAccessToken() async -> String? {
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
    

    func logout() async -> Bool {
        do {
            try await credentialsManager.revoke()
        } catch {
            print(error)
            _ = credentialsManager.clear()
        }
        return true
    }

    func login(codeCallback: (DeviceTokenRequestResponse) -> Void) async throws {
        guard let response = try? await fetchDeviceCode() else {
            return
        }

        codeCallback(response)

        let result = try await listenToResolve(deviceToken: response)

        if let r = result {
            let stored = credentialsManager.store(credentials: r)
            if !stored {
                print("couldn't store credentials")
            }
        }
    }

    private func fetchDeviceCode() async throws -> DeviceTokenRequestResponse {
        let tokenRequest = TokenRequestBody(clientId: options.client_id, scope: options.scope, audience: options.audience)

        var request = URLRequest(url: URL(string: "https://\(options.domain)/oauth/device/code")!,
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.httpBody = try? JSONEncoder().encode(tokenRequest)

        let (data, response) = try await URLSession.shared.data(for: request)

        let str = String(data: data, encoding: .utf8)

        if let httpResponse = response as? HTTPURLResponse {
            print(str as Any)
            print(httpResponse.statusCode)
        }

        return try JSONDecoder().decode(DeviceTokenRequestResponse.self, from: data)
    }

    private func listenToResolve(deviceToken: DeviceTokenRequestResponse) async throws -> Credentials? {
        let tokenRequest = GetTokenRequest(deviceCode: deviceToken.deviceCode, clientId: options.client_id)

        var request = URLRequest(url: URL(string: "https://\(options.domain)/oauth/token")!,
                                 cachePolicy: .reloadIgnoringCacheData,
                                 timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.httpBody = try? JSONEncoder().encode(tokenRequest)

        var creds: Credentials? = nil

        while true, !Task.isCancelled {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode < 200 || httpResponse.statusCode >= 300 {
                    let err = try JSONDecoder().decode(FailedTokenRetrieval.self, from: data)
                    print(err)
                    if err.error != "authorization_pending" {
                        break
                    }
                    print("Waiting to retry")
                    try await Task.sleep(nanoseconds: UInt64(deviceToken.interval * Double(NSEC_PER_SEC)))
                    continue
                }
                creds = try JSONDecoder().decode(Credentials.self, from: data)
            }
            break
        }

        return creds
    }
}

func getAgeGroup(_ age: Int?) -> String {
    let breakpoints: [Int: String] = [
        9: "< 10",
        12: "10 - 12",
        18: "13 - 18",
        25: "19 - 25",
        36: "26 - 36",
        50: "37 - 50",
        64: "51 - 64",
    ]
    
    if let age = age {
        for (key, value) in breakpoints {
            if age <= key {
                return value
            }
        }
        return "65+"
    }
    return "UNKNOWN"
}

// Profile/UserInfo
extension AuthenticationProvider {
    public struct Profile: Codable {
        let name: String?
        let ageGroup: String?
    }
    
    private static let profileKey = "profile"
    private static let profileExpiryKey = "profile_expiry"
    
    func userInfo() async -> Profile? {
        
        let ud = UserDefaults.standard
        
        if let expiry = ud.object(forKey: AuthenticationProvider.profileExpiryKey) as? Date {
            if expiry > Date.now {
                if let data = ud.object(forKey: AuthenticationProvider.profileKey) as? Data, let profile = try? JSONDecoder().decode(Profile.self, from: data) {
                    print("returning cached profile")
                    return profile
                }
            }
        }
        
        do {
            let token = await getAccessToken()
            if token == nil {
                print("no access token available")
                return nil
            }
            let userInfo = try await authentication().userInfo(withAccessToken: token!).start()
            
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = .withFractionalSeconds
            var age: Int? = nil
            
            if let bd = userInfo.birthdate {
                let date = formatter.date(from: bd)!
                let ageComponents = Calendar.current.dateComponents([.year], from: date, to: Date.now)
                age = ageComponents.year
            }
            
            let profile = Profile(
                name: userInfo.name,
                ageGroup: getAgeGroup(age)
            )
            if let encoded = try? JSONEncoder().encode(profile) {
                ud.set(encoded, forKey: AuthenticationProvider.profileKey)
            }
            ud.set(Calendar.current.date(byAdding: .minute, value: 5, to: Date.now), forKey: AuthenticationProvider.profileExpiryKey)
            return profile
        } catch {
            print("Failed to fetch userinfo")
            print(error)
        }
        return nil
    }
    
    func clearUserInfoCache() {
        UserDefaults.standard.removeObject(forKey: AuthenticationProvider.profileExpiryKey)
        UserDefaults.standard.removeObject(forKey: AuthenticationProvider.profileKey)
    }
}
