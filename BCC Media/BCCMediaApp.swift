//
//  BCCMediaApp.swift
//  appletv
//
//  Created by Fredrik Vedvik on 09/03/2023.
//
//

import SwiftUI

let authenticationProvider = AuthenticationProvider(logger: { err in
    Events.trigger(ErrorOccured(error: err.localizedDescription))
})

let apolloClient = ApolloClientFactory("https://api.brunstad.tv/query", tokenFactory: authenticationProvider.getAccessToken).NewClient()

@main
struct BCCMediaApp: App {
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
