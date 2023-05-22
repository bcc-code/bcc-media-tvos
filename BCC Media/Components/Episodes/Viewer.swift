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
    
    var playCallback: (EpisodePlayer) -> Void
    
    @FocusState var isFocused: Bool

    var body: some View {
        VStack {
            if let url = getPlayerUrl(streams: episode.streams) {
                Button {
                    playCallback(EpisodePlayer(episode: episode, playerUrl: url, startFrom: episode.progress ?? 0))
                } label: {
                    ItemImage(episode.image).frame(width: 1280, height: 720)
                }.buttonStyle(SectionItemButton(focused: isFocused)).frame(width: 1280, height: 720).overlay(
                    Image(systemName: "play.fill").resizable().frame(width: 100, height: 100)
                ).focused($isFocused)
            }
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
    
    var playCallback: (EpisodePlayer) -> Void
    
    init(_ ep: API.EpisodeSeason.Episodes.Item, playCallback: @escaping (EpisodePlayer) -> Void) {
        self.ep = ep
        self.playCallback = playCallback
    }
    
    @FocusState var isFocused: Bool
    
    var body: some View {
        NavigationLink {
            EpisodeViewer(episodeId: ep.id, playCallback: playCallback)
        } label: {
            HStack(alignment: .top, spacing: 0) {
                ItemImage(ep.image).frame(width: 320, height: 180).cornerRadius(10).padding(.zero)
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
    @State var episodeId: String
    var playCallback: (EpisodePlayer) -> Void
    
    @State private var playerUrl: URL?
    @State private var episode: API.GetEpisodeQuery.Data.Episode?
    @State private var season: API.GetEpisodeSeasonQuery.Data.Season?

    @State private var tab: Tab = .season
    @State private var seasonId: String = ""

    func loadSeason(id: String) async {
        let data = await apolloClient.getAsync(query: API.GetEpisodeSeasonQuery(id: id))
        if let s = data?.season {
            season = s
        }
    }

    func load() async {
        if episodeId == episode?.id {
            return
        }
        let data = await apolloClient.getAsync(query: API.GetEpisodeQuery(id: episodeId))
        if let e = data?.episode {
            episode = e
            seasonId = e.season?.id ?? ""
            if e.type != .episode {
                tab = .details
            }
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
        VStack {
            if let e = episode {
                ScrollView(.vertical) {
                    VStack(alignment: .leading) {
                        EpisodeHeader(episode: e, season: season, playCallback: playCallback)
                        HStack {
                            Picker(String(localized: "common_tab"), selection: $tab) {
                                if e.type == .episode {
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
                                            EpisodeListItem(ep, playCallback: playCallback)
                                        }.frame(width: 1280, height: 180)
                                    }
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
                                    Text(toDateString(e.publishDate)).font(.caption2).foregroundColor(.gray)
                                    Spacer()
                                }.focusable()
                            }
                        }
                    }.frame(width: 1280).padding(100)
                }.padding(-100)
            } else {
                ProgressView()
            }
        }.task {
            await load()
        }.onChange(of: seasonId) { id in
            if !id.isEmpty {
                Task {
                    await loadSeason(id: id)
                }
            }
        }
    }
}

extension EpisodeViewer: Hashable {
    static func == (lhs: EpisodeViewer, rhs: EpisodeViewer) -> Bool {
        lhs.episodeId == rhs.episodeId
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(episodeId)
    }
}

struct EpisodeViewer_Previews: PreviewProvider {
    static var previews: some View {
        EpisodeViewer(episodeId: "1838") { item in
            
        }
    }
}
