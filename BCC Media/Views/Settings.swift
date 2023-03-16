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
    @State var authenticated = authenticationProvider.isAuthenticated()

    func logout() {
        Task {
            _ = await authenticationProvider.logout()
            apolloClient.clearCache()
            authenticated = false
        }
    }

    func startSignIn() {
        Task {
            do {
                try await authenticationProvider.login() { (code) -> () in
                    token = code.userCode
                    verificationUri = code.verificationUri
                }
                apolloClient.clearCache()
                authenticated = true
            } catch {
                print(error)
            }
        }
    }

    @State var language = UserDefaults.standard.string(forKey: "language") ?? "no"

    var body: some View {
        NavigationStack {
            Section {
                Picker("Language", selection: $language) {
                    Text("Norwegian").tag("no")
                    Text("English").tag("en")
                    Text("Dutch").tag("nl")
                    Text("German").tag("de")
                    Text("Spanish").tag("es")
                    Text("Oko").tag("ok")
                    Text("poasd").tag("oko")
                }
                        .pickerStyle(.navigationLink).onChange(of: language) { val in
                            UserDefaults.standard.set(language, forKey: "language")
                        }
            }


            if authenticated {
                Button("Log out", action: logout)
            } else {
                Button("Sign in", action: startSignIn)
                if token != "" {
                    Text(token)
                    Text(verificationUri)
                }
            }
        }
    }
}

struct SettingsView_Preview: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
