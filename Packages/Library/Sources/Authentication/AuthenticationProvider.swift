//
// Created by Fredrik Vedvik on 09/03/2023.
//

import Auth0
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

public struct DeviceTokenRequestResponse: Codable {
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

public struct AuthenticationProviderOptions {
    var client_id: String
    var scope: String
    var audience: String
    var domain: String
}

public struct AuthenticationProvider {
    private var options: AuthenticationProviderOptions
    private var credentialsManager = Auth0.CredentialsManager(authentication: authentication())
    
    init(options: AuthenticationProviderOptions) {
        self.options = options
    }

    private enum AuthenticationError: Error {
        case emptyResponse
    }

    func isAuthenticated() -> Bool {
        credentialsManager.hasValid() || credentialsManager.canRenew()
    }

    func getAccessToken() async -> String? {
        do {
            if isAuthenticated() {
                return try await credentialsManager.credentials().accessToken
            }
        } catch {
            print("Error occured when trying to fetch access token")
            print(error)
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
        let response = try! await fetchDeviceCode()

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

// Profile/UserInfo
extension AuthenticationProvider {
    public struct Profile: Codable {
        let name: String?
    }
    
    func userInfo() async -> Profile? {
        let profileKey = "profile"
        let profileExpiryKey = "profile_expiry"
        
        let ud = UserDefaults.standard
        
        if let expiry = ud.object(forKey: profileExpiryKey) as? Date {
            if expiry > Date.now {
                if let data = ud.object(forKey: profileKey) as? Data, let profile = try? JSONDecoder().decode(Profile.self, from: data) {
                      return profile
                 }
            }
        }
        
        do {
            let token = await getAccessToken()
            if token == nil {
                return nil
            }
            let userInfo = try await authentication().userInfo(withAccessToken: token!).start()
            let profile = Profile(
                name: userInfo.name
            )
            if let encoded = try? JSONEncoder().encode(profile) {
                ud.set(encoded, forKey: profileKey)
            }
            ud.setValue(Calendar.current.date(byAdding: .day, value: 1, to: Date.now), forKey: profileExpiryKey)
        } catch {
            print("Failed to fetch userinfo")
            print(error)
        }
        return nil
    }
}
