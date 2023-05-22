//
//  Settings.swift
//  appletv
//
//  Created by Fredrik Vedvik on 16/03/2023.
//

import SwiftUI

extension String {
    var capitalizedSentence: String {
        // 1
        let firstLetter = self.prefix(1).capitalized
        // 2
        let remainingLetters = self.dropFirst().lowercased()
        // 3
        return firstLetter + remainingLetters
    }
}

struct SettingsView: View {
    @State var token = ""
    @State var verificationUri = ""
    @State var verificationUriComplete = ""
    @State var authenticated = authenticationProvider.isAuthenticated()
    var onSave: () -> Void

    @State var name: String? = nil
    @State var cancelTask: (() -> Void)? = nil
    @State var loading = false

    func reloadUserInfo() async {
        if let info = await authenticationProvider.userInfo() {
            name = info.name
        }
    }

    func authStateUpdate() {
        apolloClient.clearCache()
        authenticated = authenticationProvider.isAuthenticated()
        onSave()
        loading = false
        path.removeLast(path.count)
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
                try await authenticationProvider.login { code in
                    token = code.userCode
                    verificationUri = code.verificationUri
                    verificationUriComplete = code.verificationUriComplete
                    path.append(
                        SignInView(cancel: {
                            cancelTask?()
                            authStateUpdate()
                        }, verificationUri: verificationUri, verificationUriComplete: verificationUriComplete, code: token))
                }
                authStateUpdate()
            } catch {
                print(error)
            }
        }
        cancelTask = task.cancel
    }

    @State var audioLanguage = AppOptions.standard.audioLanguage ?? "none"
    @State var subtitleLanguage = AppOptions.standard.subtitleLanguage ?? "none"

    func setLanguage(_ key: String, _ value: String) {
        if value == "none" {
            UserDefaults.standard.removeObject(forKey: key)
        } else {
            UserDefaults.standard.setValue(value, forKey: key)
        }
        apolloClient.clearCache()
    }
    
    func getVersion() -> String {
        let versionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        let buildString = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
        
        return "\(versionString) (\(buildString))"
    }
    
    @State var path: NavigationPath = .init()

    var body: some View {
        ZStack {
            NavigationStack(path: $path) {
                VStack {
                    Form {
                        Section(header: Text("common_settings")) {
                            Picker("settings_audioLanguage", selection: $audioLanguage) {
                                Text("common_none").tag("none")
                                ForEach(Language.getAll(), id: \.code) { language in
                                    Text(language.display.capitalizedSentence).tag(language.code)
                                }
                            }.pickerStyle(.navigationLink).onChange(of: audioLanguage) { value in
                                setLanguage("audioLanguage", value)
                            }
                            Picker("settings_subtitles", selection: $subtitleLanguage) {
                                Text("common_none").tag("none")
                                ForEach(Language.getAll(), id: \.code) { language in
                                    HStack {
                                        Text(language.display.capitalizedSentence)
                                    }.tag(language.code)
                                }
                            }.pickerStyle(.navigationLink).onChange(of: subtitleLanguage) { value in
                                setLanguage("subtitleLanguage", value)
                            }
                        }
                        Section(header: Text("settings_account")) {
                            if authenticated {
                                Button {
                                    logout()
                                } label: {
                                    HStack {
                                        if let n = name {
                                            Text(n)
                                        } else {
                                            EmptyView()
                                        }
                                        Spacer()
                                        Text("settings_logOut").foregroundColor(.gray)
                                    }
                                }
                            } else {
                                Button {
                                    startSignIn()
                                } label: {
                                    if loading {
                                        ProgressView()
                                    } else {
                                        Text("settings_signIn")
                                    }
                                }
                            }
                        }
                        Section(header: Text("settings_information")) {
                            NavigationLink("settings_aboutUs") {
                                AboutUsView()
                            }
                        }
                    }
                    Spacer()
                    Text("App Version: " + getVersion()).foregroundColor(.gray)
                }.frame(maxWidth: 800)
                    .navigationDestination(for: SignInView.self) { view in
                        view
                    }.navigationDestination(for: AboutUsView.self) { view in
                        view
                    }
            }
        }
        .task {
            await reloadUserInfo()
        }
    }
}

struct SettingsView_Preview: PreviewProvider {
    static var previews: some View {
        SettingsView(onSave: {})
    }
}
