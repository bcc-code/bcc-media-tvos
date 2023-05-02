//
//  BCCMediaApp.swift
//  appletv
//
//  Created by Fredrik Vedvik on 09/03/2023.
//
//

import SwiftUI

let authenticationProvider = AuthenticationProvider()

let apolloClient = ApolloClientFactory(tokenFactory: authenticationProvider.getAccessToken).NewClient()

@main
struct BCCMediaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
