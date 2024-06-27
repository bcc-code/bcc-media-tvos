
import Auth0
import FirebaseCrashlytics
import Foundation

public func getAgeGroup(_ age: Int?) -> String {
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
        for key in breakpoints.keys.sorted() {
            let value = breakpoints[key]!
            if age <= key {
                return value
            }
        }
        return "65+"
    }
    return "UNKNOWN"
}

public extension Provider {
    struct Profile: Codable {
        public let name: String?
        public let gender: String?
        public let ageGroup: String?
        public let personId: Int?
        public let churchId: Int?
        public let countryISOCode: String?
    }
    
    private static let profileKey = "profile"
    private static let profileExpiryKey = "profile_expiry"
    
    func userInfo() async -> Profile? {
        let ud = UserDefaults.standard
        
        if let expiry = ud.object(forKey: Provider.profileExpiryKey) as? Date {
            if expiry > Date.now {
                if let data = ud.object(forKey: Provider.profileKey) as? Data, let profile = try? JSONDecoder().decode(Profile.self, from: data) {
                    print("returning cached profile")
                    print(profile)
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
            
            var personId: Int?
            if let appMetadata = userInfo.customClaims?["https://members.bcc.no/app_metadata"] as? [String: Any] {
                personId = appMetadata["personId"] as? Int
            }
            
            var age: Int?
            if let bd = userInfo.birthdate {
                age = calculateAge(from: bd)
            }
            
            let profile = Profile(
                name: userInfo.name,
                gender: userInfo.gender,
                ageGroup: getAgeGroup(age),
                personId: personId,
                churchId: userInfo.customClaims?["https://login.bcc.no/claims/churchId"] as? Int,
                countryISOCode: userInfo.customClaims?["https://login.bcc.no/claims/CountryIso2Code"] as? String
            )
            if let encoded = try? JSONEncoder().encode(profile) {
                ud.set(encoded, forKey: Provider.profileKey)
            }
            ud.set(Calendar.current.date(byAdding: .minute, value: 5, to: Date.now), forKey: Provider.profileExpiryKey)
            return profile
        } catch {
            print("Failed to fetch userinfo")
            // Create and report a custom error with detailed log information
            let customErrorInfo = [
                NSLocalizedDescriptionKey: "Failed to fetch user info",
                "original_error": error.localizedDescription,
            ]
            let customError = NSError(domain: "tv.brunstad.app", code: 9999, userInfo: customErrorInfo)
            // Report the custom error to Crashlytics
            Crashlytics.crashlytics().record(error: customError)
        }
        return nil
    }
    
    func clearUserInfoCache() {
        UserDefaults.standard.removeObject(forKey: Provider.profileExpiryKey)
        UserDefaults.standard.removeObject(forKey: Provider.profileKey)
    }
}

public func calculateAge(from birthdate: String) -> Int? {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [
        .withFractionalSeconds,
        .withFullDate, // Forces 00.00.00. This is the only way to allow fractional seconds without it being *required*. See https://forums.swift.org/t/iso8601dateformatter-fails-to-parse-a-valid-iso-8601-date/22999/19
    ]
    
    guard let date = formatter.date(from: birthdate) else {
        return nil
    }
    
    let ageComponents = Calendar.current.dateComponents([.year], from: date, to: Date())
    return ageComponents.year
}
