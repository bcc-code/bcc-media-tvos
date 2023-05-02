//
//  ContentView.swift
//  appletv
//
//  Created by Fredrik Vedvik on 09/03/2023.
//
//

import SwiftUI

var backgroundColor: Color {
    Color(red: 13 / 256, green: 22 / 256, blue: 35 / 256)
}

var cardBackgroundColor: Color {
    Color(red: 29 / 256, green: 40 / 256, blue: 56 / 256)
}

struct ContentView: View {
    @State var authenticated = authenticationProvider.isAuthenticated()
    @State var pageId = ""

    @State var loaded = false
    @State var path: NavigationPath = .init()

    func load() {
        apolloClient.fetch(query: API.GetApplicationQuery()) { result in
            switch result {
            case let .success(data):
                self.pageId = data.data?.application.page?.id ?? ""
            case let .failure(error):
                print(error)
            }
            loaded = true
        }
    }

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            NavigationStack(path: $path) {
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
                    .navigationDestination(for: EpisodeViewer.self) { episode in
                        EpisodeViewer(episodeId: episode.episodeId)
                    }
                }
            }.task {
                load()
            }
            .onOpenURL(perform: { url in
                print(url.absoluteString)

                let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!

                let parts = components.path.split(separator: "/")
                if parts.count == 0 {
                    return
                }
                if parts[0] == "episode" {
                    if parts[1] != "" {
                        let str = parts[1]
                        path.append(EpisodeViewer(episodeId: String(str)))
                    }
                }
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
