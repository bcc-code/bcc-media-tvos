
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

    /// What to do about an error from the device-code token endpoint.
    ///
    /// Internal so it can be tested — the loop below needs a live `URLSession`, but this is the part
    /// that was wrong.
    enum PollOutcome: Equatable {
        /// The user has not finished authorising yet.
        case keepWaiting
        /// The server is asking us to poll less often. RFC 8628 says add 5 seconds to the interval.
        case slowDown
        /// Terminal — the code expired, was denied, or something unrecognised came back.
        case stop
    }

    static func pollOutcome(forErrorCode code: String) -> PollOutcome {
        switch code {
        case "authorization_pending": .keepWaiting
        case "slow_down": .slowDown
        default: .stop
        }
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

            // The code is only valid for `expiresIn` seconds. Polling past that burns requests against
            // a code Auth0 has already discarded, and the loop had no other stopping condition.
            let deadline = Date().addingTimeInterval(TimeInterval(deviceToken.expiresIn))
            var interval = deviceToken.interval

            while !Task.isCancelled, Date() < deadline {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse else {
                    return nil
                }
                if httpResponse.statusCode == 200 {
                    return try JSONDecoder().decode(Credentials.self, from: data)
                }

                let failure = try JSONDecoder().decode(FailedTokenRetrieval.self, from: data)
                switch Provider.pollOutcome(forErrorCode: failure.error) {
                case .keepWaiting:
                    break
                case .slowDown:
                    // Was treated as fatal, abandoning a sign-in the user could still have completed.
                    interval += 5
                case .stop:
                    logger(DeviceCodeError(code: failure.error, detail: failure.error_description))
                    return nil
                }

                try await Task.sleep(nanoseconds: UInt64(interval * Double(NSEC_PER_SEC)))
            }

            return nil
        } catch {
            return nil
        }
    }
}

/// A terminal failure from the device-code token endpoint, so it can go through `Provider.logger`
/// rather than only being printed.
struct DeviceCodeError: Error, CustomStringConvertible {
    let code: String
    let detail: String

    var description: String {
        "device code rejected: \(code) — \(detail)"
    }
}
