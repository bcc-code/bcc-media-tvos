//
//  Player.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 19/04/2023.
//

import SwiftUI

struct EpisodePlayer: View {
    var playerUrl: URL
    var episode: API.GetEpisodeQuery.Data.Episode
    
    var listener: PlaybackListener

    init(episode: API.GetEpisodeQuery.Data.Episode, playerUrl: URL, next: @escaping () -> Void = {}) {
        self.episode = episode

        self.playerUrl = playerUrl

        listener = PlaybackListener(stateCallback: { state in
            apolloClient.perform(mutation: API.SetEpisodeProgressMutation(id: episode.id, progress: Int(state.time))) { _ in
                print("updated progress")
                print(state)
            }
        }, endCallback: {
            next()
        })
    }

    var body: some View {
        PlayerViewController(
            playerUrl,
            .init(
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
            ),
            listener).ignoresSafeArea()
    }
}

extension EpisodePlayer: Hashable {
    static func == (lhs: EpisodePlayer, rhs: EpisodePlayer) -> Bool {
        lhs.playerUrl == rhs.playerUrl
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(playerUrl)
    }
}
