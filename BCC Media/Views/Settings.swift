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

    @State var loading = false
    
    func authStateUpdate() {
        apolloClient.clearCache()
        authenticated = authenticationProvider.isAuthenticated()
        showSignIn = false
        onSave()
        loading = false
    }

    func logout() {
        loading = true
        Task {
            _ = await authenticationProvider.logout()
            authStateUpdate()
        }
    }

    func startSignIn() {
        loading = true
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

    @State var showSignIn = false

    var body: some View {
        NavigationStack {
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
                    Button {
                        startSignIn()
                    } label: {
                        if loading {
                            ProgressView()
                        } else {
                            Text("Sign in")
                        }
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
