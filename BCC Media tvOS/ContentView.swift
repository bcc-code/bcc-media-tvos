//
//  ContentView.swift
//  appletv
//
//  Created by Fredrik Vedvik on 09/03/2023.
//
//

import API
import FeatureFlags
import NpawPlugin
import SwiftUI

var backgroundColor: Color {
    Color(red: 13 / 255, green: 22 / 255, blue: 35 / 255)
}

var cardBackgroundColor: Color {
    Color(red: 29 / 255, green: 40 / 255, blue: 56 / 255)
}

var cardActiveBackgroundColor: Color {
    Color(red: 58 / 255, green: 80 / 255, blue: 112 / 255)
}

enum StaticDestination: Hashable {
    case aboutUs
    case signIn
}

enum TabType: Hashable {
    case pages
    case search
    case settings
}

typealias PlayCallback = (Bool, API.GetEpisodeQuery.Data.Episode) async -> Void

struct ContentView: View {
    @State var authenticated = authenticationProvider.isAuthenticated()
    @State var frontPageId: String? = nil
    @State var bccMember = false

    @State var loaded = false

    @State var loading = false
    @Environment(\.scenePhase) private var scenePhase

    func load() async {
        frontPageId = nil
        try? await Task.sleep(for: .seconds(1))
        await AppOptions.load()
        frontPageId = AppOptions.app.pageId
        bccMember = AppOptions.user.bccMember == true
        // Hopped to the main actor because this fires from whichever thread a failing request is on,
        // and `startSignIn` touches `@State` and the navigation path. With this, all three
        // `startSignIn` call sites are main-isolated.
        authenticationProvider.registerErrorCallback {
            Task { @MainActor in
                startSignIn()
            }
        }
        NpawPluginProvider.setup()
        if let id = AppOptions.user.anonymousId {
            setupFeatureFlags(anonymousId: id)
            await Events.standard.identify()
        } else {
            print("[Unleash] skipped — no anonymousId, flags stay off while signed out")
        }
        // Never gate the UI on Unleash: it used to only unblock from the Unleash callback, so every
        // launch waited for that request to finish or time out.
        withAnimation {
            loaded = true
        }
    }

    private func setupFeatureFlags(anonymousId: String) {
        // Only send keys we actually know. "unknown" sentinels break Unleash constraints, and a
        // shared fake userId puts every user without a personId in the same rollout bucket.
        var context = [
            "anonymousId": anonymousId,
            // Stickiness falls back to sessionId when there is no userId, keeping gradual rollouts
            // stable per device for signed-in users without a personId.
            "sessionId": anonymousId,
            "os": "tvos"
        ]
        if let personId = AppOptions.user.personId {
            context["userId"] = personId
        }
        if let ageGroup = AppOptions.user.ageGroup {
            context["ageGroup"] = ageGroup
        }
        if let ageGroupStart = AppOptions.user.ageGroupStart {
            context["ageGroupStart"] = String(ageGroupStart)
        }
        if let gender = AppOptions.user.gender {
            context["gender"] = gender
        }
        if let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
            context["appBuildNumber"] = buildNumber
        }

        FeatureFlagsClient.shared.setup(
            unleashUrl: AppOptions.unleash.url,
            clientKey: AppOptions.unleash.clientKey,
            context: context
        )
    }

    private func viewCallback(_ id: String, context: API.EpisodeContext? = nil) async {
        await loadEpisode(id, context: context)
    }

    private func getPathsFromUrl(_ url: URL) async {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!

        let parts = components.path.split(separator: "/")
        if parts.count == 0 {
            return
        }

        if parts[0] == "episode" {
            if parts[1] != "" {
                let str = parts[1]

                var play = false
                if let queryItems = components.queryItems {
                    for q in queryItems {
                        if q.name == "play" {
                            play = true
                            break
                        }
                    }
                }
                await loadEpisode(String(str), play: play)
            }
        }
    }

    func authStateUpdate() {
        apolloClient.clearCache(callbackQueue: .main) {
            print("CLEARED APOLLO CACHE")
            authenticated = authenticationProvider.isAuthenticated()
            loading = false
            path.removeLast(path.count)
            Task {
                authenticationProvider.clearUserInfoCache()
                await load()
            }
        }
    }

    func logout() {
        loading = true
        Task {
            _ = await authenticationProvider.logout()
            authStateUpdate()
        }
    }

    @State var cancelLogin: (() -> Void)? = nil
    @State private var signingIn = false

    /// Called by the two sign-in buttons and by the auth error handler. The handler fires once per
    /// failing request and several can fail together, so this has to be a no-op while a flow is
    /// already running — every flow starts by revoking credentials.
    func startSignIn() {
        guard !signingIn else {
            print("sign-in already in progress, ignoring")
            return
        }
        signingIn = true

        let task = Task { @MainActor in
            defer { signingIn = false }

            _ = await authenticationProvider.logout()

            await authenticationProvider.login { code in
                // `login` is a non-isolated async function, so its synchronous callback runs on the
                // generic executor — this needs its own hop before touching `path`.
                Task { @MainActor in
                    path.append(
                        SignInView(
                            cancel: {
                                cancelLogin?()
                            },
                            verificationUri: code.verificationUri,
                            verificationUriComplete: code.verificationUriComplete,
                            code: code.userCode
                        )
                    )
                }
            }
            authStateUpdate()
        }
        cancelLogin = task.cancel
    }

    func playCallbackWithContext(_ context: API.EpisodeContext?, progress _: Bool) -> PlayCallback {
        func cb(_ shuffle: Bool, _ episode: API.GetEpisodeQuery.Data.Episode) {
            var ctx = context ?? API.EpisodeContext()
            ctx.shuffle = .init(booleanLiteral: shuffle)
            path.append(EpisodePlayer(episode: episode, next: triggerNextEpisode(episode, ctx)))
        }
        return cb
    }

    func triggerNextEpisode(_ episode: API.GetEpisodeQuery.Data.Episode, _ context: API.EpisodeContext) -> () -> Void {
        func trigger() {
            path.removeLast(1)
            Task { @MainActor in
                guard let data = await apolloClient.getAsync(query: API.GetNextEpisodeQuery(id: episode.id, context: context), cachePolicy: .fetchIgnoringCacheCompletely) else {
                    return
                }
                if data.episode.next.isEmpty {
                    return
                }
                var ctx = context
                ctx.cursor = .init(stringLiteral: data.episode.cursor)
                print(ctx)
                try? await Task.sleep(for: .seconds(0.5))
                await loadEpisode(data.episode.next[0].id, play: true, context: ctx, progress: false)
            }
        }
        return trigger
    }

    func loadEpisode(_ id: String, play: Bool = false, context: API.EpisodeContext? = nil, progress: Bool = true) async {
        let ctx = API.EpisodeContext(
            collectionId: context?.collectionId ?? .null,
            playlistId: context?.playlistId ?? .null,
            shuffle: context?.shuffle ?? .null,
            cursor: context?.cursor ?? .null
        )
        guard let data = await apolloClient.getAsync(query: API.GetEpisodeQuery(id: id, context: .init(ctx)), cachePolicy: .fetchIgnoringCacheData) else {
            return
        }
        if play {
            path.append(EpisodePlayer(episode: data.episode, next: triggerNextEpisode(data.episode, ctx), progress: progress))
        } else {
            path.append(EpisodeViewer(episode: data.episode, context: ctx, viewCallback: viewCallback, playCallback: playCallbackWithContext(ctx, progress: progress)))
        }
    }

    func loadPlaylist(_ id: String) async {
        guard let data = await apolloClient.getAsync(query: API.GetFirstEpisodeInPlaylistQuery(id: id)) else {
            return
        }
        await loadEpisode(data.playlist.items.items[0].id, context: .init(.init(collectionId: .null, playlistId: .init(stringLiteral: id), shuffle: .null, cursor: .null)))
    }

    func loadShow(_ id: String) async {
        guard let data = await apolloClient.getAsync(query: API.GetDefaultEpisodeIdForShowQuery(id: id)) else {
            return
        }
        await loadEpisode(data.show.defaultEpisode.id)
    }

    func loadSeason(_ id: String) async {
        guard let data = await apolloClient.getAsync(query: API.GetDefaultEpisodeIdForSeasonQuery(id: id)) else {
            return
        }
        await loadEpisode(data.season.defaultEpisode.id)
    }

    func loadTopic(_ id: String) async {
        guard let data = await apolloClient.getAsync(query: API.GetDefaultEpisodeIdForStudyTopicQuery(id: id)),
              let episodeId = data.studyTopic.defaultLesson.defaultEpisode?.id
        else {
            return
        }
        await loadEpisode(episodeId)
    }

    func loadPage(_ id: String) async {
        guard let data = await apolloClient.getAsync(query: API.GetPageQuery(id: id)) else {
            return
        }
        path.append(data.page)
    }

    func clickItem(item: Item, context: API.EpisodeContext?) async {
        if item.locked {
            print("Item was locked. Ignoring click")
            return
        }

        switch item.type {
        case .episode:
            await loadEpisode(item.id, context: context)
        case .show:
            await loadShow(item.id)
        case .page:
            await loadPage(item.id)
        case .topic:
            await loadTopic(item.id)
        case .season:
            await loadSeason(item.id)
        case .playlist:
            await loadPlaylist(item.id)
        default: break
        }
    }

    @State var searchQuery = ""

    @State var path: NavigationPath = .init()
    @State var tab: TabType = .pages

    @State var onboarded = authenticationProvider.isAuthenticated()

    @State var playEpisode: API.GetEpisodeQuery.Data.Episode? = nil

    @FocusState var focusedLogin

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            if loaded {
                NavigationStack(path: $path) {
                    ZStack {
                        TabView(selection: $tab) {
                            FrontPage(pageId: frontPageId, clickItem: clickItem)
                                .tabItem {
                                    Label("tab_home", systemImage: "house.fill").font(.barlow)
                                }.tag(TabType.pages)
                            SearchView(
                                queryString: $searchQuery,
                                clickItem: clickItem,
                                playCallback: playCallbackWithContext(nil, progress: true)
                            ).tabItem {
                                Label("tab_search", systemImage: "magnifyingglass").font(.barlow)
                            }.tag(TabType.search)
                            SettingsView(
                                path: $path,
                                authenticated: authenticated,
                                onSave: {
                                    authenticated = authenticationProvider.isAuthenticated()
                                    Task {
                                        await load()
                                    }
                                },
                                signIn: startSignIn,
                                logout: logout,
                                name: AppOptions.user.name,
                                loading: loading
                            )
                            .tabItem {
                                Label("tab_settings", systemImage: "gearshape.fill").font(.barlow)
                            }.tag(TabType.settings)
                        }.disabled(!authenticated && !onboarded).font(.barlow)
                        if !authenticated && !onboarded {
                            Image(uiImage: UIImage(named: "OnboardBackground")!).resizable().ignoresSafeArea().focusable(false)
                            ZStack {
                                HStack {
                                    Image(uiImage: UIImage(named: "OnboardArt")!)
                                    VStack(alignment: .leading) {
                                        Spacer()
                                        VStack(alignment: .leading) {
                                            Text("onboard_title").font(.barlowTitle)
                                            Text("onboard_description").font(.barlow).foregroundColor(.gray)
                                        }
                                        Spacer()
                                        Button("onboard_login") {
                                            withAnimation {
                                                startSignIn()
                                                onboarded.toggle()
                                            }
                                        }.tint(.blue).focused($focusedLogin).onAppear {
                                            DispatchQueue.main.async {
                                                focusedLogin = true
                                            }
                                        }
                                        Button("onboard_explorePublic") {
                                            withAnimation {
                                                onboarded.toggle()
                                            }
                                        }
                                        Spacer()
                                    }.padding(50)
                                }
                            }.transition(.move(edge: .bottom)).zIndex(2)
                        }
                    }
                    .navigationDestination(for: EpisodeViewer.self) { viewer in
                        viewer
                    }
                    .navigationDestination(for: API.GetPageQuery.Data.Page.self) { page in
                        PageView(page, clickItem: clickItem)
                    }
                    .navigationDestination(for: SignInView.self) { view in
                        view
                    }
                    .navigationDestination(for: StaticDestination.self) { dest in
                        switch dest {
                        case .aboutUs:
                            AboutUsView()
                        default:
                            EmptyView()
                        }
                    }
                    .navigationDestination(for: EpisodePlayer.self) { player in
                        player
                    }
                }.transition(.opacity)
            }
        }.preferredColorScheme(.dark)
            .task {
                await load()
            }
            .onOpenURL(perform: { url in
                loading = true
                Task {
                    await getPathsFromUrl(url)

                    onboarded = true
                    loading = false
                }
            }).onChange(of: scenePhase) { phase in
                switch phase {
                case .active:
                    print("reload")
                    Task {
                        await load()
                    }
                default:
                    print("do nothing")
                }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
