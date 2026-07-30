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

    /// The Picker tag for "no preference". `AppOptions` stores that as an absent value, not as a string.
    private static let noSelection = "none"

    @State var audioLanguage = AppOptions.audioLanguage ?? SettingsView.noSelection
    @State var subtitleLanguage = AppOptions.subtitleLanguage ?? SettingsView.noSelection

    /// Applies a language change through `AppOptions` and reports it.
    ///
    /// This used to write `UserDefaults` directly with its own copies of the `"audioLanguage"` /
    /// `"subtitleLanguage"` key strings, duplicating `AppOptions.setAudioLanguage` /
    /// `setSubtitleLanguage` — whose key constants are `private` precisely so nobody does that. Two
    /// write paths to one key is how they drift.
    ///
    /// The previous value has to be read before the write: `@State` already holds the new one by the
    /// time `onChange` runs. Note `LanguageChanged` has no field separating audio from subtitles, so
    /// both pickers produce indistinguishable events downstream.
    enum LanguageSetting {
        case audio
        case subtitles

        var stored: String? {
            get {
                switch self {
                case .audio: AppOptions.audioLanguage
                case .subtitles: AppOptions.subtitleLanguage
                }
            }
            nonmutating set {
                switch self {
                case .audio: AppOptions.audioLanguage = newValue
                case .subtitles: AppOptions.subtitleLanguage = newValue
                }
            }
        }
    }

    func applyLanguage(_ value: String, to setting: LanguageSetting) {
        let previous = setting.stored
        setting.stored = value == SettingsView.noSelection ? nil : value

        Events.trigger(LanguageChanged(
            pageCode: "settings",
            languageFrom: previous ?? SettingsView.noSelection,
            languageTo: value
        ))

        // Cached responses embed the selected languages.
        apolloClient.clearCache {}
    }

    @State var logoutPopup = false

    var body: some View {
        VStack {
            Form {
                Section(header: Text("common_settings")) {
                    Picker("settings_audioLanguage", selection: $audioLanguage) {
                        Text("common_none").tag(SettingsView.noSelection)
                        ForEach(Language.getAll(), id: \.code) { language in
                            Text(language.display.capitalizedSentence).tag(language.code)
                        }
                    }.pickerStyle(.navigationLink).onChange(of: audioLanguage) { value in
                        applyLanguage(value, to: .audio)
                    }
                    Picker("settings_subtitles", selection: $subtitleLanguage) {
                        Text("common_none").tag(SettingsView.noSelection)
                        ForEach(Language.getAll(), id: \.code) { language in
                            HStack {
                                Text(language.display.capitalizedSentence)
                            }.tag(language.code)
                        }
                    }.pickerStyle(.navigationLink).onChange(of: subtitleLanguage) { value in
                        applyLanguage(value, to: .subtitles)
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
