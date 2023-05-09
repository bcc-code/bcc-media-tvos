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

struct FrontPage: View {
    var pageId: String
    var clickItem: (Item) -> Void

    init(pageId: String, clickItem: @escaping (Item) -> Void) {
        self.pageId = pageId
        self.clickItem = clickItem
    }

    var body: some View {
        PageView(pageId: pageId, clickItem: clickItem)
    }
}

struct ContentView: View {
    @State var authenticated = authenticationProvider.isAuthenticated()
    @State var pageId = ""

    @State var loaded = false
    @State var path: NavigationPath = .init()

    @State var loading = false

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

    func loadShow(_ id: String) {
        apolloClient.fetch(query: API.GetDefaultEpisodeIdForShowQuery(id: id)) { result in
            switch result {
            case let .success(data):
                if let episodeId = data.data?.show.defaultEpisode.id {
                    path.append(EpisodeViewer(episodeId: episodeId))
                } else if let errs = data.errors {
                    for err in errs {
                        print(err.path as Any)
                        print(err.message as Any)
                    }
                }
            case let .failure(error):
                print(error)
            }
        }
    }

    func loadTopic(_ id: String) {
        apolloClient.fetch(query: API.GetDefaultEpisodeIdForStudyTopicQuery(id: id)) { result in
            switch result {
            case let .success(data):
                if let episodeId = data.data?.studyTopic.defaultLesson.defaultEpisode?.id {
                    path.append(EpisodeViewer(episodeId: episodeId))
                } else if let errs = data.errors {
                    print(errs)
                }
            case let .failure(error):
                print(error)
            }
        }
    }

    func loadSeason(_ id: String) {
        apolloClient.fetch(query: API.GetDefaultEpisodeIdForSeasonQuery(id: id)) { result in
            switch result {
            case let .success(data):
                if let episodeId = data.data?.season.defaultEpisode.id {
                    path.append(EpisodeViewer(episodeId: episodeId))
                } else if let errs = data.errors {
                    print(errs)
                }
            case let .failure(error):
                print(error)
            }
        }
    }

    func clickItem(item: Item) {
        if item.locked {
            return
        }
        switch item.type {
        case .episode:
            path.append(EpisodeViewer(episodeId: item.id))
        case .show:
            loadShow(item.id)
        case .page:
            path.append(PageView(pageId: item.id, clickItem: clickItem))
        case .topic:
            loadTopic(item.id)
        case .season:
            loadSeason(item.id)
        }
    }

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            NavigationStack(path: $path) {
                VStack {
                    if loaded && !loading && path.isEmpty {
                        TabView {
                            FrontPage(pageId: pageId, clickItem: clickItem).tabItem {
                                Label("tab_home", systemImage: "house.fill")
                            }
                            if authenticated {
                                LiveView().tabItem {
                                    Label("tab_live", systemImage: "video")
                                }
                            }
                            SearchView().tabItem {
                                Label("tab_search", systemImage: "magnifyingglass")
                            }
                            SettingsView {
                                authenticated = authenticationProvider.isAuthenticated()
                            }.tabItem {
                                Label("tab_settings", systemImage: "gearshape.fill")
                            }
                        }
                    }
                }
                .navigationDestination(for: EpisodeViewer.self) { episode in
                    EpisodeViewer(
                        episodeId: episode.episodeId
                    )
                }
                .navigationDestination(for: PageView.self) { page in
                    PageView(
                        pageId: page.pageId,
                        clickItem: clickItem
                    )
                }
                .navigationDestination(for: EpisodePlayer.self) { player in
                    EpisodePlayer(
                        title: player.title,
                        playerUrl: player.playerUrl,
                        startFrom: player.startFrom
                    ).ignoresSafeArea()
                }
            }.task {
                load()
            }
            .onOpenURL(perform: { url in
                loading = true
                let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!

                let parts = components.path.split(separator: "/")
                if parts.count == 0 {
                    return
                }
                if parts[0] == "episode" {
                    if parts[1] != "" {
                        let str = parts[1]
                        if let queryItems = components.queryItems {
                            for q in queryItems {
                                if q.name == "play" {
                                    apolloClient.fetch(query: API.GetEpisodeQuery(id: String(str))) { result in
                                        switch result {
                                        case let .success(res):
                                            if let streams = res.data?.episode.streams, let playerUrl = getPlayerUrl(streams: streams) {
                                                print("Adding player to path")
                                                path.append(EpisodePlayer(title: res.data?.episode.title, playerUrl: playerUrl, startFrom: res.data?.episode.progress ?? 0))
                                            }
                                        case .failure:
                                            print("Failed to retrieve stream from episode")
                                        }
                                        loading = false
                                    }
                                    return
                                }
                            }
                        }
                        path.append(EpisodeViewer(episodeId: String(str)))
                        loading = false
                    }
                }
            })
        }.preferredColorScheme(.dark)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
