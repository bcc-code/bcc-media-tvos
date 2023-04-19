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
    
    @State var name: String? = nil

    @State var cancelTask: (() -> Void)? = nil

    @State var loading = false
    
    func reloadUserInfo() async -> Void {
        if let info = await authenticationProvider.userInfo() {
            name = info.name
        }
    }
    
    func authStateUpdate() {
        apolloClient.clearCache()
        authenticated = authenticationProvider.isAuthenticated()
        showSignIn = false
        onSave()
        loading = false
        Task {
            await reloadUserInfo()
        }
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
    
    @State var appLanguage = "en"

    var body: some View {
        NavigationStack {
            if showSignIn {
                SignInView(cancel: {
                    cancelTask?()
                    authStateUpdate()
                }, verificationUri: verificationUri, verificationUriComplete: verificationUriComplete, code: token)
            } else {
                VStack {
                    Form {
                        Section(header: Text("Settings")) {
                            Picker("App Language", selection: $appLanguage) {
                                Text("English").tag("en")
                                Text("Norsk").tag("no")
                                Text("Deutsch").tag("de")
                            }.pickerStyle(.navigationLink)
                            Picker("Audio Language", selection: $appLanguage) {
                                Text("English").tag("en")
                                Text("Norsk").tag("no")
                                Text("Deutsch").tag("de")
                            }.pickerStyle(.navigationLink)
                            Picker("Subtitles", selection: $appLanguage) {
                                Text("English").tag("en")
                                Text("Norsk").tag("no")
                                Text("Deutsch").tag("de")
                            }.pickerStyle(.navigationLink)
                        }
                        Section(header: Text("Account")) {
                            HStack {
                                if let n = name {
                                    Text(n)
                                } else {
                                    Text("Name")
                                }
                                Spacer()
                                Button("Okay") {
                                    print("what")
                                }
                            }
                            if authenticated {
                                Button {
                                    logout()
                                } label: {
                                    HStack {
                                        if let n = name {
                                            Text(n)
                                        } else {
                                            Text("Log out")
                                        }
                                        Spacer()
                                        Text("Log out").foregroundColor(.gray)
                                    }
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
                }.frame(maxWidth: 800)
            }
        }.task {
            await reloadUserInfo()
        }
    }
}

struct SettingsView_Preview: PreviewProvider {
    static var previews: some View {
        SettingsView(onSave: {})
    }
}
