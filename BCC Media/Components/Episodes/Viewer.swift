//
// Created by Fredrik Vedvik on 13/03/2023.
//

import SwiftUI

struct EpisodeViewer: View {
    @State var episodeId: String
    @State private var playerUrl: URL?
    @State private var episode: API.GetEpisodeQuery.Data.Episode?

    func getPlayerUrl() -> URL? {
        if let streams = episode?.streams {
            let types = [API.StreamType.hlsCmaf, API.StreamType.hlsTs, API.StreamType.dash]
            var index = 0
            var stream = streams.first(where: { $0.type == types[index] })
            while stream == nil && (types.count - 1) > index {
                index += 1
                stream = streams.first(where: { $0.type == types[index] })
            }
            if stream == nil {
                stream = streams.first
            }
            if let stream = stream {
                return URL(string: stream.url)
            }
        }
        return nil
    }

    var body: some View {
        VStack {
            if let e = episode {
                ScrollView(.vertical) {
                    VStack {
                        VStack {
                            if let url = getPlayerUrl() {
                                NavigationLink {
                                    EpisodePlayer(title: e.title, playerUrl: url)
                                } label: {
                                    ItemImage(e.image).frame(width: 800, height: 450)
                                }.buttonStyle(.card).frame(width: 800, height: 450)
                            }
                            Text(e.title).padding(20)
                        }.background(cardBackgroundColor)
                        VStack {
                            Text(e.description)
                        }
                        VStack (alignment: .leading, spacing: 10) {
                            ForEach(e.season?.episodes.items ?? [], id: \.id) { ep in
                                NavigationLink {
                                    EpisodeViewer(episodeId: ep.id)
                                } label: {
                                    HStack(alignment: .top, spacing: 0) {
                                        ItemImage(ep.image).frame(width: 320, height: 180).cornerRadius(10).padding(.zero)
                                        VStack(alignment: .leading) {
                                            Text(ep.title).font(.subheadline).foregroundColor(.blue)
                                            Text(ep.description).font(.body)
                                        }.padding(20)
                                        Spacer()
                                    }.frame(maxWidth: .infinity).background(cardBackgroundColor)
                                }.buttonStyle(.card).padding(.zero)
                            }.frame(width: 800, height: 180)
                        }
                    }.frame(width: 800).padding(100)
                }.padding(-100)
            } else {
                ProgressView()
            }
        }.task {
            apolloClient.fetch(query: API.GetEpisodeQuery(id: episodeId)) { result in
                switch result {
                case let .success(res):
                    if let e = res.data?.episode {
                        episode = e
                    }
                case .failure:
                    print("FAILURE")
                }
            }
        }
    }
}

struct EpisodeViewer_Previews: PreviewProvider {
    static var previews: some View {
        EpisodeViewer(episodeId: "1768")
    }
}
