//
//  Options.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 12/05/2023.
//

import Foundation

private let audioLanguageKey = "audioLanguage"
private let subtitleLanguageKey = "subtitleLanguage"

public struct UserOptions {
    var anonymousId: String?
    var ageGroup: String?
}

public struct ApplicationOptions {
    var pageId: String?
}

public struct NpawOptions {
    var accountCode: String?
}

public struct RudderOptions {
    var dataPlaneUrl: String = ""
    var writeKey: String = ""
}

public struct AppOptions {
    private init() {}
    
    public var name: String = "tvOS"
    
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
    
    public var user: UserOptions = UserOptions()
    
    public var app: ApplicationOptions = ApplicationOptions()
    
    public var npaw: NpawOptions = NpawOptions()
    
    public var rudder: RudderOptions = RudderOptions()
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
    
    static func load() async -> Void {
        do {
            let data = try await withCheckedThrowingContinuation { continuation in
                apolloClient.fetch(query: API.GetSetupQuery()) { result in
                    switch result {
                    case .success(let response):
                        continuation.resume(returning: response.data!)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
            
            AppOptions.standard.app.pageId = data.application.page?.id
            
            if authenticationProvider.isAuthenticated() {
                let userInfo = await authenticationProvider.userInfo()
                AppOptions.user.anonymousId = data.me.analytics.anonymousId
                AppOptions.user.ageGroup = userInfo?.ageGroup
            }
            
            let processInfo = ProcessInfo.processInfo
            
            AppOptions.standard.npaw.accountCode = processInfo.environment["NPAW_ACCOUNTCODE"]
            AppOptions.standard.rudder.writeKey = processInfo.environment["RUDDER_WRITEKEY"] ?? ""
            AppOptions.standard.rudder.dataPlaneUrl = processInfo.environment["RUDDER_DATAPLANEURL"] ?? ""
        } catch {
            print(error)
        }
    }
}