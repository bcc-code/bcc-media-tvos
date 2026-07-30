//
//  BCCMediaApp.swift
//  appletv
//
//  Created by Fredrik Vedvik on 09/03/2023.
//
//

import API
import Authentication
import FeatureFlags
import Firebase
import NpawPlugin
import SwiftUI
import Sentry

let authenticationProvider = Authentication.Provider(serviceName: "bcc.media", accessGroup: "group.tv.brunstad.app.tvos", logger: { err in
    Events.trigger(ErrorOccured(error: err.localizedDescription))
})

func getSessionId() -> String? {
    return AppOptions.standard.sessionId
}
func getSearchSessionId() -> String? {
    return AppOptions.searchSessionId
}

func getFeatureFlagsHeader() -> String? {
    return FeatureFlagsClient.shared.headerValue
}

/// Sentry has been initialised since launch, but until now the only `capture` in the app was in
/// `Userinfo`. GraphQL and transport errors were printed and dropped, so nothing about a failing API
/// was visible outside a debugger.
func reportApiError(_ error: Error) {
    print("api error: \(error)")
    SentrySDK.capture(error: error)
    Events.trigger(ErrorOccured(error: error.localizedDescription))
}

let apolloClient = API.NewClient(
    apiUrl: "https://api.brunstad.tv/query",
    tokenFactory: authenticationProvider.getAccessToken,
    sessionIdFactory: getSessionId,
    searchSessionIdFactory: getSearchSessionId,
    featureFlagsFactory: getFeatureFlagsHeader,
    reportError: reportApiError
)

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_: UIApplication,
                     didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool
    {
        FirebaseApp.configure()
        
        SentrySDK.start{ options in
            options.dsn = ProcessInfo.processInfo.environment["SENTRY_DSN"] ?? CI.sentryDsn
            options.tracesSampleRate = 0.5
        }
        
        return true
    }
}

@main
struct BCC_Media_tvOSApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @Environment(\.scenePhase) private var scenePhase

    @State private var coldStart = true

    var body: some Scene {
        WindowGroup {
            ContentView().onAppear {
                // Initialize rudder SDK
                _ = Events.standard
            }.onChange(of: scenePhase) { _, phase in
                switch phase {
                case .background:
                    print("in background")
                case .active:
                    print("active")
                    Events.trigger(ApplicationOpened(
                        reason: "Default",
                        coldStart: coldStart
                    ))
                    coldStart = false
                case .inactive:
                    print("inactive")
                @unknown default:
                    print("unknown state")
                }
            }
        }
    }
}
