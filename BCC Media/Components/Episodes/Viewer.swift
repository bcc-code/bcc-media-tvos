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

    var body: some View {
        VStack {
            if let url = getPlayerUrl(streams: episode.streams) {
                NavigationLink {
                    EpisodePlayer(title: episode.title, playerUrl: url, startFrom: episode.progress ?? 0)
                } label: {
                    ItemImage(episode.image).frame(width: 1280, height: 720)
                }.buttonStyle(.card).frame(width: 1280, height: 720).overlay(
                    Image(systemName: "play.fill").resizable().frame(width: 100, height: 100)
                )
            }
        }
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading) {
                Text(episode.title).font(.title3)
                HStack(spacing: 5) {
                    Text(episode.ageRating).background(
                        Rectangle().foregroundColor(cardBackgroundColor)
                    )
                    if let s = season {
                        Text(s.show.title).font(.subheadline).foregroundColor(.blue)
                    }
                }
            }
            Text(episode.description).font(.caption)
        }.padding(.vertical, 20)
    }
}

struct EpisodeViewer: View {
    @State var episodeId: String
    @State private var playerUrl: URL?
    @State private var episode: API.GetEpisodeQuery.Data.Episode?
    @State private var season: API.GetEpisodeSeasonQuery.Data.Season?

    @State private var tab: Tab = .season
    @State private var seasonId: String = ""

    func loadSeason(id: String) {
        print("LOADING SEASON")
        print(id)
        apolloClient.fetch(query: API.GetEpisodeSeasonQuery(id: id)) { result in
            switch result {
            case let .success(res):
                if let s = res.data?.season {
                    season = s
                }
            case let .failure(error):
                print(error)
            }
        }
    }

    func load() {
        if episodeId == episode?.id {
            return
        }
        print("LOADING EPISODE")
        apolloClient.fetch(query: API.GetEpisodeQuery(id: episodeId)) { result in
            switch result {
            case let .success(res):
                if let e = res.data?.episode {
                    episode = e
                    seasonId = e.season?.id ?? ""
                }
            case .failure:
                print("FAILURE")
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
                        EpisodeHeader(episode: e, season: season)
                        HStack {
                            Picker("Tab", selection: $tab) {
                                Text("Episodes").tag(Tab.season)
                                Text("Details").tag(Tab.details)
                            }.pickerStyle(.segmented)
                        }
                        switch tab {
                        case .season:
                            VStack {
                                if let s = season {
                                    Picker("Season", selection: $seasonId) {
                                        ForEach(s.show.seasons.items, id: \.id) { se in
                                            Text(se.title).tag(se.id)
                                        }
                                    }.pickerStyle(.navigationLink).disabled(s.show.seasons.items.count <= 1)
                                    VStack(alignment: .leading, spacing: 10) {
                                        ForEach(s.episodes.items, id: \.id) { ep in
                                            NavigationLink {
                                                EpisodeViewer(episodeId: ep.id)
                                            } label: {
                                                HStack(alignment: .top, spacing: 0) {
                                                    ItemImage(ep.image).frame(width: 320, height: 180).cornerRadius(10).padding(.zero)
                                                    VStack(alignment: .leading) {
                                                        Text(ep.title).font(.subheadline)
                                                        Text(ep.description).font(.caption2).foregroundColor(.gray)
                                                    }.padding(20)
                                                    Spacer()
                                                }.frame(maxWidth: .infinity).background(cardBackgroundColor)
                                            }.buttonStyle(.card).padding(.zero)
                                        }.frame(width: 1280, height: 180)
                                    }
                                }
                            }
                        case .details:
                            ScrollView(.vertical) {
                                VStack(alignment: .leading) {
                                    if let s = season {
                                        Text("Show description").bold().font(.caption)
                                        Text(s.show.description).font(.caption2).foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Text("Release date").bold().font(.caption)
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
            load()
        }.onChange(of: seasonId) { id in
            if !id.isEmpty {
                loadSeason(id: id)
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
        EpisodeViewer(episodeId: "1838")
    }
}
