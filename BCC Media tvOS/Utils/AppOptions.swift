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

public struct NpawOptions {
    var accountCode: String?
}

public struct RudderOptions {
    var dataPlaneUrl: String = ""
    var writeKey: String = ""
}

public struct UnleashOptions {
    var url: String = ""
    var clientKey: String = ""
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
            AppOptions.user.bccMember = data.me.bccMember
            AppOptions.user.personId = userInfo?.personId?.formatted()
            AppOptions.user.countryISOCode = userInfo?.countryISOCode
            AppOptions.user.churchId = userInfo?.churchId?.formatted()
        } else {
            AppOptions.user = .init()
        }

        let processInfo = ProcessInfo.processInfo

        AppOptions.standard.npaw.accountCode = processInfo.environment["NPAW_ACCOUNT_CODE"] ?? CI.npawAccountCode
        AppOptions.standard.rudder.writeKey = processInfo.environment["RUDDER_WRITE_KEY"] ?? CI.rudderWriteKey
        AppOptions.standard.rudder.dataPlaneUrl = processInfo.environment["RUDDER_DATA_PLANE_URL"] ?? CI.rudderDataplaneURL
        AppOptions.standard.unleash.url = processInfo.environment["UNLEASH_URL"] ?? CI.unleashUrl
        AppOptions.standard.unleash.clientKey = processInfo.environment["UNLEASH_CLIENT_KEY"] ?? CI.unleashClientKey
    }
}
