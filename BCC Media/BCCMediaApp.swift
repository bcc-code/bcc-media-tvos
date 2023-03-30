//
//  BCCMediaApp.swift
//  appletv
//
//  Created by Fredrik Vedvik on 09/03/2023.
//
//

import SwiftUI

let authenticationProvider = AuthenticationProvider(options: AuthenticationProviderOptions(client_id: "rJbKSHYPskua2BgY8mEwOSasK6o6uCRA", scope: "profile email offline_access", audience: "api.bcc.no", domain: "login.bcc.no"))

let apolloClient = ApolloClientFactory(tokenFactory: authenticationProvider.getAccessToken).NewClient()

@main
struct BCCMediaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
