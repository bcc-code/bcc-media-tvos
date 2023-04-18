//
//  ContentView.swift
//  appletv
//
//  Created by Fredrik Vedvik on 09/03/2023.
//
//

import SwiftUI

struct ContentView: View {
    @State var authenticated = authenticationProvider.isAuthenticated()
    @State var pageId = ""
    
    @State var loaded = false
    
    func load() {
        apolloClient.fetch(query: API.GetApplicationQuery()) { result in
            switch result {
            case .success(let data):
                self.pageId = data.data?.application.page?.id ?? ""
            case .failure(let error):
                print(error)
            }
            loaded = true
        }
        
    }

    var body: some View {
        ZStack {
            Color.init(red: 13/256, green: 22/256, blue: 35/256).ignoresSafeArea()
            NavigationView {
                if loaded {
                    TabView {
                        PageView(pageId: pageId).tabItem {
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
            }.task {
                load()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
