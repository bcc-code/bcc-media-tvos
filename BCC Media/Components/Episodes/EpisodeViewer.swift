//
// Created by Fredrik Vedvik on 13/03/2023.
//

import SwiftUI

internal enum Tab {
    case season
    case details
}

struct EpisodeHeader: View {
    var episode: API.GetEpisodeQuery.Data.Episode
    var season: API.GetEpisodeSeasonQuery.Data.Season?

    var playCallback: (EpisodePlayer) async -> Void

    @FocusState var isFocused: Bool

    var body: some View {
        VStack {
            Button {
                Task {
                    if let url = getPlayerUrl(streams: episode.streams) {
                        await playCallback(EpisodePlayer(episode: episode, playerUrl: url, startFrom: episode.progress ?? 0))
                    }
                }
            } label: {
                ItemImage(episode.image).frame(width: 1280, height: 720).overlay(
                    Image(systemName: "play.fill").resizable().frame(width: 100, height: 100)
                ).overlay(
                    LockView(locked: getPlayerUrl(streams: episode.streams) == nil)
                )
            }.buttonStyle(SectionItemButton(focused: isFocused)).frame(width: 1280, height: 720).focused($isFocused)
        }
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 5) {
                Text(episode.title).font(.title2)
                HStack(spacing: 5) {
                    Text(episode.ageRating).padding([.horizontal], 10).padding(.vertical, 5).background(
                        Rectangle().foregroundColor(cardBackgroundColor)).cornerRadius(10)
                    if let s = season {
                        Text(s.show.title).font(.subheadline).foregroundColor(.blue)
                    }
                }
            }
            Text(episode.description).font(.caption)
        }.padding(.vertical, 20)
    }
}

struct EpisodeListItem: View {
    var ep: API.EpisodeSeason.Episodes.Item
    var click: () async -> Void
    
    @State private var loading = false

    init(_ ep: API.EpisodeSeason.Episodes.Item, click: @escaping () async -> Void) {
        self.ep = ep
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
                ItemImage(ep.image).frame(width: 320, height: 180).cornerRadius(10).padding(.zero).overlay(
                    ZStack {
                        if loading {
                            Color.black.opacity(0.4)
                            ProgressView()
                        }
                    }
                )
                VStack(alignment: .leading) {
                    Text(ep.title).font(.subheadline)
                    Text(ep.description).font(.caption2).foregroundColor(.gray)
                }.padding(20)
                Spacer()
            }.frame(maxWidth: .infinity).background(cardBackgroundColor)
        }.buttonStyle(SectionItemButton(focused: isFocused))
            .padding(.zero)
            .focused($isFocused)
    }
}

struct EpisodeViewer: View {
    var episode: API.GetEpisodeQuery.Data.Episode
    var viewCallback: (String) async -> Void
    var playCallback: (EpisodePlayer) async -> Void

    @State private var playerUrl: URL?
    @State private var season: API.GetEpisodeSeasonQuery.Data.Season?

    @State private var tab: Tab = .season
    @State private var seasonId: String = ""

    func loadSeason(_ id: String) async {
        let data = await apolloClient.getAsync(query: API.GetEpisodeSeasonQuery(id: id))
        if let s = data?.season {
            season = s
        }
    }

    func toDateString(_ str: String) -> String {
        let parser = DateFormatter()
        parser.locale = Locale(identifier: "en_US_POSIX")
        parser.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = parser.date(from: str)!

        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy HH:mm"
        formatter.locale = .autoupdatingCurrent

        return formatter.string(from: date)
    }

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                EpisodeHeader(episode: episode, season: season, playCallback: playCallback)
                HStack {
                    Picker(String(localized: "common_tab"), selection: $tab) {
                        if episode.type == .episode {
                            Text("common_episodes").tag(Tab.season)
                        }
                        Text("common_details").tag(Tab.details)
                    }.pickerStyle(.segmented)
                }
                switch tab {
                case .season:
                    VStack {
                        if let s = season {
                            Picker(String(localized: "common_seasons"), selection: $seasonId) {
                                ForEach(s.show.seasons.items, id: \.id) { se in
                                    Text(se.title).tag(se.id)
                                }
                            }.pickerStyle(.navigationLink).disabled(s.show.seasons.items.count <= 1)
                            VStack(alignment: .leading, spacing: 20) {
                                ForEach(s.episodes.items, id: \.id) { ep in
                                    EpisodeListItem(ep) {
                                        await viewCallback(ep.id)
                                    }.disabled(ep.id == episode.id)
                                }.frame(width: 1280, height: 180)
                            }.focusSection()
                        }
                    }
                case .details:
                    ScrollView(.vertical) {
                        VStack(alignment: .leading) {
                            if let s = season {
                                Text("shows_description").bold().font(.caption)
                                Text(s.show.description).font(.caption2).foregroundColor(.gray)
                            }
                            Spacer()
                            Text("episodes_releaseDate").bold().font(.caption)
                            Text(toDateString(episode.publishDate)).font(.caption2).foregroundColor(.gray)
                            Spacer()
                        }.focusable()
                    }
                }
            }.frame(width: 1280).padding(100)
        }.padding(-100)
        .onAppear {
            seasonId = episode.season?.id ?? ""
        }.onChange(of: seasonId) { id in
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
