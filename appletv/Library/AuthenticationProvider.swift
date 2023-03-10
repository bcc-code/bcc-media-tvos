//
// Created by Fredrik Vedvik on 09/03/2023.
//

import Foundation
import Auth0

private struct tokenRequestBody: Codable {
    var client_id: String
    var scope: String
    var audience: String
}

struct DeviceTokenRequestResponse: Codable {
    var device_code: String
    var user_code: String
    var verification_uri: String
    var expires_in: Int
    var interval: Double
    var verification_uri_complete: String
}

struct AuthenticationProviderOptions {
    var client_id: String
    var scope: String
    var audience: String
    var domain: String
}

struct GetTokenRequest: Codable {
    var grant_type = "urn:ietf:params:oauth:grant-type:device_code"
    var device_code: String
    var client_id: String
}

struct FailedTokenRetrieval: Codable {
    var error: String
    var error_description: String
}

struct AuthenticationProvider {
    var options: AuthenticationProviderOptions
    var credentialsManager = Auth0.CredentialsManager(authentication: authentication())

    enum AuthenticationError: Error {
        case emptyResponse
    }

    func isAuthenticated() -> Bool {
        credentialsManager.hasValid()
    }

    func getAccessToken(codeCallback: (String) -> Void) async throws -> String {
        if credentialsManager.hasValid() {
            return try await credentialsManager.credentials().accessToken
        }

        let deviceCode = try! await fetchDeviceCode()

        codeCallback(deviceCode.device_code)

        let result = try! await listenToResolve(deviceToken: deviceCode)

        let stored = credentialsManager.store(credentials: result)
        if (!stored) {
            print("couldn't store credentials")
        }
        return result.accessToken
    }

    func login(codeCallback: (String) -> Void) async throws -> Void {
        let deviceCode = try! await fetchDeviceCode()

        codeCallback(deviceCode.user_code)

        let result = try! await listenToResolve(deviceToken: deviceCode)

        let stored = credentialsManager.store(credentials: result)
        if (!stored) {
            print("couldn't store credentials")
        }
    }

    func fetchDeviceCode() async throws -> DeviceTokenRequestResponse {
        let tokenRequest = tokenRequestBody(client_id: options.client_id, scope: options.scope, audience: options.audience)

        var request = URLRequest(url: URL(string: "https://\(options.domain)/oauth/device/code")!,
                cachePolicy: .useProtocolCachePolicy,
                timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.httpBody = try? JSONEncoder().encode(tokenRequest)

        let (data, response) = try await URLSession.shared.data(for: request)

        var str = String(data: data, encoding: .utf8)

        if let httpResponse = response as? HTTPURLResponse {
            print(str)
            print(httpResponse.statusCode)
        }

        return try JSONDecoder().decode(DeviceTokenRequestResponse.self, from: data)
    }

    func listenToResolve(deviceToken: DeviceTokenRequestResponse) async throws -> Credentials {
        let tokenRequest = GetTokenRequest(device_code: deviceToken.device_code, client_id: options.client_id)

        var request = URLRequest(url: URL(string: "https://\(options.domain)/oauth/token")!,
                cachePolicy: .reloadIgnoringCacheData,
                timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.httpBody = try? JSONEncoder().encode(tokenRequest)

        var creds: Credentials? = nil

        while true {
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

        return creds!
    }
}
