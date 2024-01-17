
import Foundation
import Auth0

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
    public var deviceCode: String
    public var userCode: String
    public var verificationUri: String
    public var expiresIn: Int
    public var interval: Double
    public var verificationUriComplete: String

    enum CodingKeys: String, CodingKey {
        case deviceCode = "device_code"
        case userCode = "user_code"
        case verificationUri = "verification_uri"
        case expiresIn = "expires_in"
        case interval = "interval"
        case verificationUriComplete = "verification_uri_complete"
    }
}

extension Provider {
    public func login(codeCallback: (DeviceTokenRequestResponse) -> Void) async {
        guard let response = try? await fetchDeviceCode() else {
            return
        }

        codeCallback(response)

        let result = await listenToResolve(deviceToken: response)

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

    private func listenToResolve(deviceToken: DeviceTokenRequestResponse) async -> Credentials? {
        do {
            let tokenRequest = GetTokenRequest(deviceCode: deviceToken.deviceCode, clientId: options.client_id)

            var request = URLRequest(url: URL(string: "https://\(options.domain)/oauth/token")!,
                                     cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                     timeoutInterval: 10.0)
            
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "content-type")
            request.httpBody = try JSONEncoder().encode(tokenRequest)

            var creds: Credentials? = nil

            while true, !Task.isCancelled {
                let (data, response) = try await URLSession.shared.data(for: request)
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        creds = try JSONDecoder().decode(Credentials.self, from: data)
                        break
                    }
                    let err = try JSONDecoder().decode(FailedTokenRetrieval.self, from: data)
                    print(err)
                    if err.error != "authorization_pending" {
                        break
                    }
                    print("Waiting to retry")
                    try await Task.sleep(nanoseconds: UInt64(deviceToken.interval * Double(NSEC_PER_SEC)))
                    continue
                }
                break
            }

            return creds
        } catch {
            return nil
        }
    }
}
