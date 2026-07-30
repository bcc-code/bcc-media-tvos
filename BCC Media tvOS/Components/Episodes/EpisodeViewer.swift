//
// Created by Fredrik Vedvik on 13/03/2023.
//

import API
import SwiftUI

internal enum Tab {
    case collection
    case season
    case details
}

struct EpisodeHeader: View {
    var episode: API.GetEpisodeQuery.Data.Episode
    var season: API.GetEpisodeSeasonQuery.Data.Season?

    var playCallback: PlayCallback

    @FocusState var isFocused: Bool

    @State private var inMyList: Bool

    init(
        episode: API.GetEpisodeQuery.Data.Episode,
        season: API.GetEpisodeSeasonQuery.Data.Season?,
        playCallback: @escaping PlayCallback
    ) {
        self.episode = episode
        self.season = season
        self.playCallback = playCallback
        // Seeded here rather than from `.onAppear`. Doing it in onAppear had two costs: it tripped the
        // `onChange` that used to drive the mutation, and it re-applied the stale fetched value on every
        // reappearance — so coming back from the player discarded a toggle the user had just made.
        _inMyList = State(initialValue: episode.inMyList)
    }

    /// Runs the mutation from the user's action rather than from a state change.
    ///
    /// `onChange(of: inMyList)` used to drive it, which meant *anything* assigning `inMyList` fired a
    /// mutation. Opening an episode already in My List therefore re-added it, every time.
    private func toggleMyList() {
        inMyList.toggle()

        if inMyList {
            apolloClient.perform(mutation: API.AddEpisodeToMyListMutation(id: episode.id))
        } else {
            apolloClient.perform(mutation: API.RemoveEpisodeFromMyListMutation(id: API.UUID(episode.uuid)))
        }
    }

    var body: some View {
        VStack {
            Button {
                Task {
                    await playCallback(false, episode)
                }
            } label: {
                ItemImage(episode.image).frame(width: 1280, height: 720).overlay(
                    Image(systemName: "play.fill").resizable().frame(width: 100, height: 100)
                ).overlay(
                    LockView(locked: episode.locked)
                )
            }
            .buttonStyle(SectionItemButton(focused: isFocused))
            .frame(width: 1280, height: 720)
            // Was found via buttons["Play"], which only worked because SF Symbols gives `play.fill`
            // an implicit "Play" label.
            .accessibilityIdentifier("PlayEpisode")
            .focused($isFocused)
        }
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(episode.title).font(.barlowTitle)
                    HStack(spacing: 5) {
                        Text(episode.ageRating).font(.barlow).padding([.horizontal], 10).padding(.vertical, 5).background(
                            Rectangle().foregroundColor(Color.cardBackground)).cornerRadius(10)
                        if let s = season {
                            Text(s.show.title).font(.barlow).foregroundColor(.blue)
                        }
                    }
                }
                Spacer()
                HStack {
                    Button {
                        Task {
                            await playCallback(true, episode)
                        }
                    } label: {
                        Image(systemName: "shuffle")
                    }.buttonStyle(.plain)
                    if authenticationProvider.isAuthenticated() {
                        Button {
                            toggleMyList()
                        } label: {
                            if inMyList {
                                Image(systemName: "heart.fill")
                            } else {
                                Image(systemName: "heart")
                            }
                        }.buttonStyle(.plain)
                    }
                }
            }
            if let desc = try? AttributedString(markdown: episode.description, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)) {
                Text(desc).font(.barlowCaption)
            }
        }.padding(.vertical, 20)
            .font(.barlow)
    }
}

struct EpisodeListItem: View {
    var title: String
    var description: String
    var image: String?
    var click: () async -> Void
    var active: Bool

    @State private var loading = false

    init(title: String, description: String, image: String?, active: Bool, click: @escaping () async -> Void) {
        self.title = title
        self.description = description
        self.image = image
        self.active = active
        self.click = click
    }

    @FocusState var isFocused: Bool

    var body: some View {
        Button {
            Task {
                loading = true
                await click()
                loading = false
            }
        } label: {
            HStack(alignment: .top, spacing: 0) {
                ItemImage(image).frame(width: 320, height: 180).cornerRadius(10).padding(.zero).overlay(
                    ZStack {
                        if loading {
                            Color.black.opacity(0.4)
                            ProgressView()
                        }
                    }
                )
                VStack(alignment: .leading) {
                    Text(title).font(.barlow)
                    if let desc = try? AttributedString(markdown: description, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)) {
                        Text(desc).font(.barlowCaption).foregroundColor(.gray)
                    }
                }.padding(20)
                Spacer()
            }.frame(maxWidth: .infinity)
                .background(active ? Color.cardActiveBackground : Color.cardBackground)
        }.buttonStyle(SectionItemButton(focused: isFocused))
            .padding(.zero)
            .focused($isFocused)
    }
}

struct EpisodeViewer: View {
    var episode: API.GetEpisodeQuery.Data.Episode
    var context: API.EpisodeContext?
    var viewCallback: (String, API.EpisodeContext?) async -> Void
    var playCallback: PlayCallback

    @State private var playerUrl: URL?
    @State private var season: API.GetEpisodeSeasonQuery.Data.Season?
    @State private var items: [API.GetEpisodeContextQuery.Data.Episode.Context.AsContextCollection.Items.Item]?

    @State private var tab: Tab = .season
    @State private var seasonId: String = ""

    @State private var loaded = false

    func loadSeason(_ id: String) async {
        let data = await apolloClient.getAsync(query: API.GetEpisodeSeasonQuery(id: id))
        if let s = data?.season {
            season = s
        }
    }

    func load() async {
        if loaded {
            return
        }
        // The Picker only emits a `.season` tag for episodes, so for anything else the default
        // selection matched no tag and the segmented control rendered with nothing active. Corrected
        // before the first `await`, so there is no window where the selection is invalid.
        if episode.type != .episode {
            tab = .details
        }
        let data = await apolloClient.getAsync(query: API.GetEpisodeContextQuery(id: episode.id, context: context != nil ? .init(context!) : .null))
        if let c = data?.episode.context?.asContextCollection?.items?.items {
            items = c
            tab = .collection
        } else {
            seasonId = episode.season?.id ?? ""
        }
        loaded = true
    }

    /// Fixed-format parser for the API's publish date. `en_US_POSIX` so the device locale cannot change
    /// how the pattern is interpreted.
    private static let publishDateParser: DateFormatter = {
        let parser = DateFormatter()
        parser.locale = Locale(identifier: "en_US_POSIX")
        parser.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return parser
    }()

    /// `.autoupdatingCurrent` rather than `.current`, which is what makes caching the instance safe —
    /// it follows a locale change instead of freezing the one in effect at first use.
    private static let publishDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy HH:mm"
        formatter.locale = .autoupdatingCurrent
        return formatter
    }()

    func toDateString(_ str: String) -> String {
        // Show the raw value rather than trapping if the API ever returns a shape this pattern does
        // not cover (fractional seconds, for instance).
        guard let date = Self.publishDateParser.date(from: str) else {
            return str
        }
        return Self.publishDateFormatter.string(from: date)
    }

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                EpisodeHeader(episode: episode, season: season, playCallback: playCallback)
                HStack {
                    Picker(String(localized: "common_tab"), selection: $tab) {
                        if items != nil {
                            Text("common_videos").tag(Tab.collection).font(.barlow)
                        } else if episode.type == .episode {
                            Text("common_episodes").tag(Tab.season).font(.barlow)
                        }
                        Text("common_details").tag(Tab.details)
                    }.pickerStyle(.segmented).font(.barlow)
                }
                switch tab {
                case .collection:
                    VStack {
                        if let items = items {
                            VStack(alignment: .leading, spacing: 20) {
                                ForEach(items, id: \.id) { ep in
                                    EpisodeListItem(title: ep.title, description: ep.description, image: ep.image, active: ep.id == episode.id) {
                                        if ep.id == episode.id { return }
                                        await viewCallback(ep.id, context)
                                    }
                                }.frame(width: 1280, height: 180)
                            }.focusSection()
                        }
                    }
                case .season:
                    VStack {
                        if let s = season {
                            Picker(String(localized: "common_seasons"), selection: $seasonId) {
                                ForEach(s.show.seasons.items, id: \.id) { se in
                                    Text(se.title).tag(se.id).font(.barlow)
                                }
                            }.pickerStyle(.navigationLink).font(.barlow).disabled(s.show.seasons.items.count <= 1)
                            VStack(alignment: .leading, spacing: 20) {
                                ForEach(s.episodes.items, id: \.id) { ep in
                                    EpisodeListItem(title: ep.title, description: ep.description, image: ep.image, active: ep.id == episode.id) {
                                        if ep.id == episode.id { return }
                                        await viewCallback(ep.id, context)
                                    }
                                }.frame(width: 1280, height: 180)
                            }.focusSection()
                        }
                    }
                case .details:
                    VStack(alignment: .leading) {
                        if let s = season {
                            Text("shows_description").bold().font(.barlow)
                            Text(s.show.description).font(.barlowCaption).foregroundColor(.gray)
                        }
                        Spacer()
                        Text("episodes_releaseDate").bold().font(.barlow)
                        Text(toDateString(episode.publishDate)).font(.barlowCaption).foregroundColor(.gray)
                        Spacer()
                    }.focusable()
                }
            }.frame(width: 1280).padding(100)
        }.padding(-100)
            .task {
                await load()
            }
            .onChange(of: seasonId) { id in
                print(id)
                if !id.isEmpty {
                    Task {
                        await loadSeason(id)
                    }
                }
            }
    }
}

extension EpisodeViewer: Hashable {
    static func == (lhs: EpisodeViewer, rhs: EpisodeViewer) -> Bool {
        return lhs.episode.id == rhs.episode.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(episode.id)
    }
}
