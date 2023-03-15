//
//  ContentView.swift
//  appletv
//
//  Created by Fredrik Vedvik on 09/03/2023.
//
//

import SwiftUI

struct ContentView: View {
    @State var token = ""
    @State var verificationUri = ""

    @State var page: API.GetPageQuery.Data.Page? = nil

    @State var authenticated = authenticationProvider.isAuthenticated()

    func logout() {
        Task {
            _ = await authenticationProvider.logout()
            authenticated = false
        }
    }
    
    func startSignIn() {
        Task {
            do {
                try await authenticationProvider.login() {(code) -> () in
                    token = code.userCode
                    verificationUri = code.verificationUri
                }
                authenticated = true
            } catch {
                print(error)
            }
        }
    }

    var body: some View {
        NavigationView {
            TabView {
                PageView(pageId: "29").tabItem { Label("Home", systemImage: "house.fill")}
                HStack {
                    if authenticated {
                        HStack {
                            Button("Log out", action: logout)
                        }
                    } else {
                        HStack {
                            Button("Sign in", action: startSignIn)
                            if token != "" {
                                Text(token)
                                Text(verificationUri)
                            }
                        }
                    }
                }.tabItem { Label("Settings", systemImage: "gear") }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
