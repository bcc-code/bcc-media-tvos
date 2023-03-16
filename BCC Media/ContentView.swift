//
//  ContentView.swift
//  appletv
//
//  Created by Fredrik Vedvik on 09/03/2023.
//
//

import SwiftUI

struct ContentView: View {
    @State var page: API.GetPageQuery.Data.Page? = nil
    @State var authenticated = authenticationProvider.isAuthenticated()

    var body: some View {
        NavigationView {
            TabView {
                PageView(pageId: "29").tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                if authenticated {
                    LiveView().tabItem {
                        Label("Live", systemImage: "video")
                    }
                }
                SearchView().tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                SettingsView {
                    authenticated = authenticationProvider.isAuthenticated()
                }.tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
