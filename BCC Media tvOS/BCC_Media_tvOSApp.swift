//
//  BCCMediaApp.swift
//  appletv
//
//  Created by Fredrik Vedvik on 09/03/2023.
//
//

import API
import Authentication
import Firebase
import NpawPlugin
import SwiftUI
import Sentry

let authenticationProvider = Authentication.Provider(serviceName: "bcc.media", accessGroup: "group.tv.brunstad.app.tvos", logger: { err in
    Events.trigger(ErrorOccured(error: err.localizedDescription))
})

let apolloClient = API.NewClient(apiUrl: "https://api.brunstad.tv/query", tokenFactory: authenticationProvider.getAccessToken)

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_: UIApplication,
                     didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool
    {
        FirebaseApp.configure()
        
        SentrySDK.start{ options in
            options.dsn = "https://3ffd6244935a49dab6913bdc148d8d41@o1045703.ingest.us.sentry.io/4504299662278656"
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
            }.onChange(of: scenePhase) { phase in
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
