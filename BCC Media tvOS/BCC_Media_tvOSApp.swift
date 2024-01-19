//
//  BCCMediaApp.swift
//  appletv
//
//  Created by Fredrik Vedvik on 09/03/2023.
//
//

import SwiftUI
import API
import Authentication
import NpawPlugin

let authenticationProvider = Authentication.Provider(serviceName: "bcc.media", accessGroup: "group.tv.brunstad.app.tvos", logger: { err in
    Events.trigger(ErrorOccured(error: err.localizedDescription))
})

let apolloClient = API.NewClient(apiUrl: "https://api.brunstad.tv/query", tokenFactory: authenticationProvider.getAccessToken)

@main
struct BCC_Media_tvOSApp: App {
    @Environment(\.scenePhase) private var scenePhase

    @State private var coldStart = true

    var body: some Scene {
        WindowGroup {
            ContentView().onAppear {
                // Initialize rudder SDK
                _ = Events.standard
                NpawPluginProvider.setup()
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
