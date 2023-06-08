//
// Created by Fredrik Vedvik on 13/03/2023.
//

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

    var body: some View {
        VStack {
            Button {
                Task {
                    await playCallback(episode)
                }
            } label: {
                ItemImage(episode.image).frame(width: 1280, height: 720).overlay(
                    Image(systemName: "play.fill").resizable().frame(width: 100, height: 100)
                ).overlay(
                    LockView(locked: episode.locked)
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
    var title: String
    var description: String
    var image: String?
    var click: () async -> Void

    @State private var loading = false

    init(title: String, description: String, image: String?, click: @escaping () async -> Void) {
        self.title = title
        self.description = description
        self.image = image
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
                    Text(title).font(.subheadline)
                    Text(description).font(.caption2).foregroundColor(.gray)
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
    var context: API.EpisodeContext?
    var viewCallback: (String, API.EpisodeContext?) async -> Void
    var playCallback: PlayCallback

    @State private var playerUrl: URL?
    @State private var season: API.GetEpisodeSeasonQuery.Data.Season?
    @State private var items: [API.GetEpisodeContextQuery.Data.Episode.Context.AsContextCollection.Items.Item]?

    @State private var tab: Tab = .season
    @State private var seasonId: String = ""
   
    func loadSeason(_ id: String) async {
        let data = await apolloClient.getAsync(query: API.GetEpisodeSeasonQuery(id: id))
        if let s = data?.season {
            season = s
        }
    }
    
    func load() async {
        let data = await apolloClient.getAsync(query: API.GetEpisodeContextQuery(id: episode.id, context: context != nil ? .init(context!) : .null))
        if let c = data?.episode.context?.asContextCollection?.items?.items {
            items = c
            tab = .collection
        } else {
            seasonId = episode.season?.id ?? ""
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
                        if items != nil {
                            Text("common_videos").tag(Tab.collection)
                        } else if episode.type == .episode {
                            Text("common_episodes").tag(Tab.season)
                        }
                        Text("common_details").tag(Tab.details)
                    }.pickerStyle(.segmented)
                }
                switch tab {
                case .collection:
                    VStack {
                        if let items = items {
                            VStack(alignment: .leading, spacing: 20) {
                                ForEach(items, id: \.id) { ep in
                                    EpisodeListItem(title: ep.title, description: ep.description, image: ep.image) {
                                        await viewCallback(ep.id, context)
                                    }.disabled(ep.id == episode.id)
                                }.frame(width: 1280, height: 180)
                            }.focusSection()
                        }
                    }
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
                                    EpisodeListItem(title: ep.title, description: ep.description, image: ep.image) {
                                        await viewCallback(ep.id, context)
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
            .task {
                await load()
            }
            .onChange(of: seasonId) { id in
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
