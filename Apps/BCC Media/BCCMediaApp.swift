//
//  BCCMediaApp.swift
//  appletv
//
//  Created by Fredrik Vedvik on 09/03/2023.
//
//

import SwiftUI
import Authentication
import API

struct AuthConfig {
    var domain: String = "login.bcc.no"
    var clientId: String = "rJbKSHYPskua2BgY8mEwOSasK6o6uCRA"
    var audience: String = "api.bcc.no"
}

let authConfig = AuthConfig()

let authenticationProvider = AuthenticationProvider(options: AuthenticationProviderOptions(client_id: authConfig.clientId, scope: "openid profile email offline_access", audience: authConfig.audience, domain: authConfig.domain))

let apolloClient = ApolloClientFactory(tokenFactory: authenticationProvider.getAccessToken).NewClient()

@main
struct BCCMediaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
