//
//  Player.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 19/04/2023.
//

import SwiftUI

struct EpisodePlayer: View {
    var episode: API.GetEpisodeQuery.Data.Episode
    
    var listener: PlaybackListener

    init(episode: API.GetEpisodeQuery.Data.Episode, next: @escaping () -> Void = {}) {
        self.episode = episode

        listener = PlaybackListener(stateCallback: { state in
            apolloClient.perform(mutation: API.SetEpisodeProgressMutation(id: episode.id, progress: Int(state.time))) { _ in
                print("updated progress")
                print(state)
            }
        }, endCallback: {
            next()
        })
    }
    
    @State var url: URL? = nil
    @State var options: PlayerViewController.Options? = nil
    
    func load() async {
        print("LOADING")
        let data = await apolloClient.getAsync(query: API.GetEpisodeStreamsQuery(id: episode.id))
        url = getPlayerUrl(streams: data!.episode.streams)
        options = .init(
            title: episode.title,
            startFrom: episode.progress ?? 0,
            isLive: false,
            content: .init(
                episodeTitle: episode.title,
                id: episode.id,
                seasonTitle: episode.season?.title,
                seasonId: episode.season?.id,
                showTitle: episode.season?.show.title,
                showId: episode.season?.show.id
            )
        )
    }

    var body: some View {
        Group {
            if let url = url, let options = options {
                PlayerViewController(
                    url,
                    options,
                    listener
                ).ignoresSafeArea()
            }
        }.task {
            await load()
        }
    }
}

extension EpisodePlayer: Hashable {
    static func == (lhs: EpisodePlayer, rhs: EpisodePlayer) -> Bool {
        lhs.episode.id == rhs.episode.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(episode.id)
    }
}
