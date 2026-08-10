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
    var gender: String?
    var countryISOCode: String?
    var personId: String?
    var churchId: String?
}

public struct ApplicationOptions {
    var pageId: String?
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

/// Process-wide configuration and user state.
///
/// A `final class` rather than a `struct` behind a mutable `static var`. It was always a singleton
/// with reference semantics in practice, and the struct form had a concrete cost: `static var app` was
/// get-only, so writers reached through `AppOptions.standard.app.…` while readers used
/// `AppOptions.app.…` — two spellings for the same thing, on adjacent lines inside `load()`.
public final class AppOptions {
    private init() {}

    public var sessionId: String? {
        Events.sessionId?.stringValue
    }

    /// Guarded because it is read by the Apollo interceptor on whichever thread a request is on, and
    /// written from the main actor when the search field is cleared. The rest of the state below is
    /// touched only from the main actor.
    private let lock = NSLock()
    private var storedSearchSessionId = UUID().uuidString

    public var searchSessionId: String {
        get {
            lock.lock()
            defer { lock.unlock() }
            return storedSearchSessionId
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            storedSearchSessionId = newValue
        }
    }

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

// Static conveniences, so call sites read `AppOptions.user` rather than `AppOptions.standard.user`.
// Every one of these is get *and* set, so there is a single spelling for both directions.
public extension AppOptions {
    static let standard = AppOptions()

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
        get {
            AppOptions.standard.app
        } set {
            AppOptions.standard.app = newValue
        }
    }

    static var searchSessionId: String {
        get {
            AppOptions.standard.searchSessionId
        } set {
            AppOptions.standard.searchSessionId = newValue
        }
    }

    // Stateless — these resolve env/CI on access, so there is nothing to set.
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

        AppOptions.app.pageId = data.application.page?.id

        if authenticationProvider.isAuthenticated() {
            let userInfo = await authenticationProvider.userInfo()
            AppOptions.user.name = userInfo?.name
            AppOptions.user.anonymousId = data.me.analytics.anonymousId
            AppOptions.user.ageGroup = userInfo?.ageGroup
            AppOptions.user.ageGroupStart = userInfo?.ageGroupStart
            AppOptions.user.gender = userInfo?.gender
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
