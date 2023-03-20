//
//  Settings.swift
//  appletv
//
//  Created by Fredrik Vedvik on 16/03/2023.
//

import SwiftUI

struct SettingsView: View {
    @State var token = ""
    @State var verificationUri = ""
    @State var verificationUriComplete = ""
    @State var authenticated = authenticationProvider.isAuthenticated()
    var onSave: () -> Void

    func logout() {
        Task {
            _ = await authenticationProvider.logout()
            apolloClient.clearCache()
            authenticated = false
            onSave()
        }
    }

    func startSignIn() {
        Task {
            do {
                try await authenticationProvider.login() { (code) -> () in
                    token = code.userCode
                    verificationUri = code.verificationUri
                    verificationUriComplete = code.verificationUriComplete
                    showSignIn = true
                }
                apolloClient.clearCache()
                authenticated = true
                onSave()
            } catch {
                print(error)
            }
        }
    }

    @State var language = UserDefaults.standard.string(forKey: "language") ?? "no"

    @State var showSignIn = false

    var body: some View {
        NavigationStack {
            if showSignIn {
                SignInView(cancel: {
                    showSignIn = false
                }, verificationUri: verificationUri, verificationUriComplete: verificationUriComplete, code: token)
            } else {
                if authenticated {
                    Button("Log out") {
                        logout()
                    }
                } else {
                    Button("Sign in") {
                        startSignIn()
                    }
                }
            }
        }
    }
}

struct SettingsView_Preview: PreviewProvider {
    static var previews: some View {
        SettingsView(onSave: {})
    }
}
