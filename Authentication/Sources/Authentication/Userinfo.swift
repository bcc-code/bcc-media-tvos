
import Auth0
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
        public let ageGroup: String?
        public let personId: Int?
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
            
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [
                .withFractionalSeconds,
                .withFullDate, // Make time always 00.00.00. This is the only way to get fractional seconds to be optional. See https://forums.swift.org/t/iso8601dateformatter-fails-to-parse-a-valid-iso-8601-date/22999/19
            ]
            var age: Int?
            
            if let bd = userInfo.birthdate {
                let date = formatter.date(from: bd)
                if let date = date {
                    let ageComponents = Calendar.current.dateComponents([.year], from: date, to: Date.now)
                    age = ageComponents.year
                }
            }
            
            let profile = Profile(
                name: userInfo.name,
                ageGroup: getAgeGroup(age),
                personId: personId
            )
            if let encoded = try? JSONEncoder().encode(profile) {
                ud.set(encoded, forKey: Provider.profileKey)
            }
            ud.set(Calendar.current.date(byAdding: .minute, value: 5, to: Date.now), forKey: Provider.profileExpiryKey)
            return profile
        } catch {
            print("Failed to fetch userinfo")
            print(error)
        }
        return nil
    }
    
    func clearUserInfoCache() {
        UserDefaults.standard.removeObject(forKey: Provider.profileExpiryKey)
        UserDefaults.standard.removeObject(forKey: Provider.profileKey)
    }
}
