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

    @State var page: API.GetPageQuery.Data.Page? = nil

    
    func startSignIn() {
        Task {
            do {
                try await authenticationProvider.login() {(code) -> () in
                    token = code
                }
                print("LOGGED IN")
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
                    if authenticationProvider.isAuthenticated() {
                        Text("AUTHENTICATED")
                    } else {
                        HStack {
                            Button("Sign in", action: startSignIn)
                            if token != "" {
                                Text(token)
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
