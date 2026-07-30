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
        let firstLetter = prefix(1).capitalized
        // 2
        let remainingLetters = dropFirst().lowercased()
        // 3
        return firstLetter + remainingLetters
    }
}

struct SettingsView: View {
    @Binding var path: NavigationPath

    var authenticated: Bool

    var signIn: () -> Void
    var logout: () -> Void

    var name: String?
    var loading: Bool

    @State var audioLanguage = AppOptions.standard.audioLanguage ?? "none"
    @State var subtitleLanguage = AppOptions.standard.subtitleLanguage ?? "none"

    func setLanguage(_ key: String, _ value: String) {
        if value == "none" {
            UserDefaults.standard.removeObject(forKey: key)
        } else {
            UserDefaults.standard.setValue(value, forKey: key)
        }
        apolloClient.clearCache() {

        }
    }

    /// Read the persisted value *before* `setLanguage` overwrites it — the `@State` already holds the
    /// new one by the time `onChange` runs.
    ///
    /// Note `LanguageChanged` carries no field distinguishing audio from subtitles, so both changes
    /// produce indistinguishable events downstream.
    func reportLanguageChange(from previous: String?, to value: String) {
        Events.trigger(LanguageChanged(
            pageCode: "settings",
            languageFrom: previous ?? "none",
            languageTo: value
        ))
    }

    @State var logoutPopup = false

    var body: some View {
        VStack {
            Form {
                Section(header: Text("common_settings")) {
                    Picker("settings_audioLanguage", selection: $audioLanguage) {
                        Text("common_none").tag("none")
                        ForEach(Language.getAll(), id: \.code) { language in
                            Text(language.display.capitalizedSentence).tag(language.code)
                        }
                    }.pickerStyle(.navigationLink).onChange(of: audioLanguage) { value in
                        let previous = AppOptions.audioLanguage
                        setLanguage("audioLanguage", value)
                        reportLanguageChange(from: previous, to: value)
                    }
                    Picker("settings_subtitles", selection: $subtitleLanguage) {
                        Text("common_none").tag("none")
                        ForEach(Language.getAll(), id: \.code) { language in
                            HStack {
                                Text(language.display.capitalizedSentence)
                            }.tag(language.code)
                        }
                    }.pickerStyle(.navigationLink).onChange(of: subtitleLanguage) { value in
                        let previous = AppOptions.subtitleLanguage
                        setLanguage("subtitleLanguage", value)
                        reportLanguageChange(from: previous, to: value)
                    }
                }
                Section(header: Text("settings_account")) {
                    if authenticated {
                        Button {
                            logoutPopup = true
                        } label: {
                            HStack {
                                if let name = name {
                                    Text(name)
                                } else {
                                    EmptyView()
                                }
                                Spacer()
                                Text("settings_logOut").foregroundColor(.red)
                            }
                        }.confirmationDialog("settings_logOutConfirm", isPresented: $logoutPopup, titleVisibility: .visible) {
                            Button("settings_logOut", role: .destructive) {
                                logout()
                            }
                        }
                    } else {
                        Button {
                            signIn()
                        } label: {
                            if loading {
                                ProgressView()
                            } else {
                                Text("settings_signIn")
                            }
                        }.tint(.blue)
                    }
                }
                Section(header: Text("settings_information")) {
                    Button("settings_aboutUs") {
                        path.append(StaticDestination.aboutUs)
                    }
                }
            }
            Spacer()
            Text("App Version: " + getVersion()).foregroundColor(.gray)
        }.frame(maxWidth: 800)
            .scrollClipDisabled()
            .onAppear {
                Events.page("settings")
            }.font(.barlow)
    }
}

struct SettingsView_Preview: PreviewProvider {
    @State static var path: NavigationPath = .init()

    static var previews: some View {
        SettingsView(path: $path, authenticated: false, signIn: {}, logout: {}, name: nil, loading: false)
    }
}
