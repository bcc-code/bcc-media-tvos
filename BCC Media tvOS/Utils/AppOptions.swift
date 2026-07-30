//
//  Options.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 12/05/2023.
//

import API
import Foundation

private let audioLanguageKey = "audioLanguage"
private let subtitleLanguageKey = "subtitleLanguage"

public struct UserOptions {
    var name: String?
    var anonymousId: String?
    var ageGroup: String?
    var ageGroupStart: Int?
    var bccMember: Bool?
    var gender: String?
    var countryISOCode: String?
    var personId: String?
    var churchId: String?
}

public struct ApplicationOptions {
    var pageId: String?
    var searchPageId: String?
}

// Build-time configuration: the scheme / CI environment wins, falling back to the literals in
// `CI.swift` that `envsubst` fills in during a release build.
//
// Derived rather than assigned, for two reasons. Each variable name is now spelled in exactly one
// place — `RUDDER_DATA_PLANE_URL` was misspelled in `load()` and silently shadowed the value
// `Events` had already read correctly. And these values are available from process start rather
// than only after whichever writer ran first: `load()` is async and gated on a network round trip,
// so `Events.init` used to re-resolve them itself to avoid waiting for it.
//
// Read once — `ProcessInfo.environment` rebuilds its dictionary on every access, and nothing here
// calls `setenv`.
private let processEnvironment = ProcessInfo.processInfo.environment

private func configValue(_ envKey: String, _ fallback: String) -> String {
    processEnvironment[envKey] ?? fallback
}

public struct NpawOptions {
    var accountCode: String? { configValue("NPAW_ACCOUNT_CODE", CI.npawAccountCode) }
}

public struct RudderOptions {
    var dataPlaneUrl: String { configValue("RUDDER_DATAPLANE_URL", CI.rudderDataplaneURL) }
    var writeKey: String { configValue("RUDDER_WRITE_KEY", CI.rudderWriteKey) }
}

public struct UnleashOptions {
    var url: String { configValue("UNLEASH_URL", CI.unleashUrl) }
    var clientKey: String { configValue("UNLEASH_CLIENT_KEY", CI.unleashClientKey) }
}

public struct AppOptions {
    private init() {}

    public var name: String = "tvOS"
    
    public var sessionId: String? {
        Events.sessionId?.stringValue
    }
    public var searchSessionId: String? = UUID().uuidString

    public var audioLanguage: String? {
        UserDefaults.standard.string(forKey: audioLanguageKey)
    }

    public func setAudioLanguage(_ value: String?) {
        if let value = value {
            UserDefaults.standard.set(value, forKey: audioLanguageKey)
        } else {
            UserDefaults.standard.removeObject(forKey: audioLanguageKey)
        }
    }

    public var subtitleLanguage: String? {
        UserDefaults.standard.string(forKey: subtitleLanguageKey)
    }

    public func setSubtitleLanguage(_ value: String?) {
        if let value = value {
            UserDefaults.standard.set(value, forKey: subtitleLanguageKey)
        } else {
            UserDefaults.standard.removeObject(forKey: subtitleLanguageKey)
        }
    }

    public var user: UserOptions = .init()

    public var app: ApplicationOptions = .init()

    public var npaw: NpawOptions = .init()

    public var rudder: RudderOptions = .init()

    public var unleash: UnleashOptions = .init()
}

// Implement standard things
public extension AppOptions {
    static var standard = AppOptions()

    static var audioLanguage: String? {
        get {
            AppOptions.standard.audioLanguage
        } set {
            AppOptions.standard.setAudioLanguage(newValue)
        }
    }

    static var subtitleLanguage: String? {
        get {
            AppOptions.standard.subtitleLanguage
        } set {
            AppOptions.standard.setSubtitleLanguage(newValue)
        }
    }

    static var user: UserOptions {
        get {
            AppOptions.standard.user
        } set {
            AppOptions.standard.user = newValue
        }
    }

    static var app: ApplicationOptions {
        AppOptions.standard.app
    }

    static var npaw: NpawOptions {
        AppOptions.standard.npaw
    }

    static var rudder: RudderOptions {
        AppOptions.standard.rudder
    }

    static var unleash: UnleashOptions {
        AppOptions.standard.unleash
    }

    static func load() async {
        guard let data = await apolloClient.getAsync(query: API.GetSetupQuery()) else {
            return
        }

        AppOptions.standard.app.pageId = data.application.page?.id
        AppOptions.standard.app.searchPageId = data.application.searchPage?.id

        if authenticationProvider.isAuthenticated() {
            let userInfo = await authenticationProvider.userInfo()
            AppOptions.user.name = userInfo?.name
            AppOptions.user.anonymousId = data.me.analytics.anonymousId
            AppOptions.user.ageGroup = userInfo?.ageGroup
            AppOptions.user.ageGroupStart = userInfo?.ageGroupStart
            AppOptions.user.gender = userInfo?.gender
            AppOptions.user.bccMember = data.me.bccMember
            // Not .formatted() — that applies locale grouping, so 19254 became "19 254" (with a
            // non-breaking space) and the Unleash userId changed with the device language.
            AppOptions.user.personId = userInfo?.personId.map(String.init)
            AppOptions.user.countryISOCode = userInfo?.countryISOCode
            AppOptions.user.churchId = userInfo?.churchId?.formatted()
        } else {
            AppOptions.user = .init()
        }
    }
}
