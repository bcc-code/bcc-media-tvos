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

// This is a struct to distinguish the first page component from any subpages.
struct FrontPage: View {
    var page: API.GetPageQuery.Data.Page
    var clickItem: (Item) -> Void

    init(page: API.GetPageQuery.Data.Page, clickItem: @escaping (Item) -> Void) {
        self.page = page
        self.clickItem = clickItem
    }

    var body: some View {
        PageView(page: page, clickItem: clickItem)
    }
}

enum TabType: Hashable {
    case pages
    case live
    case search
    case settings
}

struct ContentView: View {
    @State var authenticated = authenticationProvider.isAuthenticated()
    @State var frontPage: API.GetPageQuery.Data.Page? = nil
    @State var bccMember = false

    @State var loaded = false

    @State var loading = false

    func load() async -> Void {
        await AppOptions.load()
        if let pageId = AppOptions.app.pageId {
            self.frontPage = await getPage(pageId)
            self.bccMember = AppOptions.user.bccMember == true
        }
        loaded = true
    }
    
    func playCallback(_ player: EpisodePlayer) {
        path.append(player)
    }

    func loadShow(_ id: String) async {
        let data = await apolloClient.getAsync(query: API.GetDefaultEpisodeIdForShowQuery(id: id))
        if let episodeId = data?.show.defaultEpisode.id {
            path.append(EpisodeViewer(episodeId: episodeId, playCallback: playCallback))
        }
    }
    
    func loadSeason(_ id: String) async {
        let data = await apolloClient.getAsync(query: API.GetDefaultEpisodeIdForSeasonQuery(id: id))
        if let episodeId = data?.season.defaultEpisode.id {
            path.append(EpisodeViewer(episodeId: episodeId, playCallback: playCallback))
        }
    }

    func loadTopic(_ id: String) async {
        let data = await apolloClient.getAsync(query: API.GetDefaultEpisodeIdForStudyTopicQuery(id: id))
        if let episodeId = data?.studyTopic.defaultLesson.defaultEpisode?.id {
            path.append(EpisodeViewer(episodeId: episodeId, playCallback: playCallback))
        }
    }
    
    func getPage(_ id: String) async -> API.GetPageQuery.Data.Page {
        let data = await apolloClient.getAsync(query: API.GetPageQuery(id: id))
        return data!.page
    }

    func clickItemAsync(item: Item) async {
        if item.locked {
            print("Item was locked. Ignoring click")
            return
        }
        switch item.type {
        case .episode:
            print("Navigating to episode")
            path.append(EpisodeViewer(episodeId: item.id, playCallback: playCallback))
        case .show:
            print("Loading show")
            await loadShow(item.id)
        case .page:
            path.append(PageView(page: await getPage(item.id), clickItem: clickItem))
        case .topic:
            await loadTopic(item.id)
        case .season:
            await loadSeason(item.id)
        }
    }
    
    func clickItem(item: Item) {
        Task {
            await clickItemAsync(item: item)
        }
    }
    
    @State var path: NavigationPath = .init()
    
    @State var tab: TabType = .pages
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
                NavigationStack(path: $path) {
                    ZStack {
                        if loaded && !loading, let p = frontPage {
                            TabView(selection: $tab) {
                                FrontPage(page: p, clickItem: clickItem)
                                    .tabItem {
                                        Label("tab_home", systemImage: "house.fill")
                                    }.tag(TabType.pages)
                                if authenticated && bccMember {
                                    LiveView().tabItem {
                                        Label("tab_live", systemImage: "video")
                                    }.tag(TabType.live)
                                }
                                SearchView(clickItem: { item in
                                    Task {
                                        await clickItemAsync(item: item)
                                    }
                                }, playCallback: playCallback).tabItem {
                                    Label("tab_search", systemImage: "magnifyingglass")
                                }.tag(TabType.search)
                                SettingsView {
                                    authenticated = authenticationProvider.isAuthenticated()
                                    Task {
                                        await load()
                                    }
                                }.tabItem {
                                    Label("tab_settings", systemImage: "gearshape.fill")
                                }.tag(TabType.settings)
                            }
                        }
                    }
                    .navigationDestination(for: EpisodeViewer.self) { episode in
                        episode
                    }
                    .navigationDestination(for: PageView.self) { page in
                        page
                    }
                    .navigationDestination(for: EpisodePlayer.self) { player in
                        player.ignoresSafeArea()
                    }
            }
        }.preferredColorScheme(.dark)
            .task {
            await load()
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
                                        if let episode = res.data?.episode, let playerUrl = getPlayerUrl(streams: episode.streams) {
                                            print("Adding player to path")
                                            path.append(EpisodeViewer(episodeId: String(str), playCallback: playCallback))
                                            path.append(EpisodePlayer(episode: episode, playerUrl: playerUrl, startFrom: res.data?.episode.progress ?? 0))
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
                    path.append(EpisodeViewer(episodeId: String(str), playCallback: playCallback))
                }
            }
            loading = false
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
