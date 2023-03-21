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

    @State var cancelTask: (() -> Void)? = nil
    
    func authStateUpdate() {
        apolloClient.clearCache()
        authenticated = authenticationProvider.isAuthenticated()
        showSignIn = false
        onSave()
    }

    func logout() {
        Task {
            _ = await authenticationProvider.logout()
            authStateUpdate()
        }
    }

    func startSignIn() {
        let task = Task {
            do {
                try await authenticationProvider.login { (code) -> () in
                    token = code.userCode
                    verificationUri = code.verificationUri
                    verificationUriComplete = code.verificationUriComplete
                    showSignIn = true
                }
                authStateUpdate()
            } catch {
                print(error)
            }
        }
        cancelTask = task.cancel
    }

    @State var language = UserDefaults.standard.string(forKey: "language") ?? "no"

    @State var showSignIn = false

    var body: some View {
        if showSignIn {
            SignInView(cancel: {
                cancelTask?()
                authStateUpdate()
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

struct SettingsView_Preview: PreviewProvider {
    static var previews: some View {
        SettingsView(onSave: {})
    }
}
