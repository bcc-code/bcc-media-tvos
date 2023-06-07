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

    var startFrom: Int

    var listener: PlaybackListener

    init(_ episode: API.GetEpisodeQuery.Data.Episode, playerUrl: URL, startFrom: Int = 0) {
        self.episode = episode

        self.playerUrl = playerUrl
        self.startFrom = startFrom

        listener = PlaybackListener(stateCallback: { state in
            if state.time.isNaN {
                return
            }
            apolloClient.perform(mutation: API.SetEpisodeProgressMutation(id: episode.id, progress: Int(state.time))) { _ in
                print("updated progress")
                print(state)
            }
        })
    }
    
    func getPlayerOptions(_ episode: API.GetEpisodeQuery.Data.Episode) -> PlayerOptions {
        PlayerOptions(
            title: episode.title,
            startFrom: startFrom,
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
        PlayerViewController(
            playerUrl,
            getPlayerOptions(episode),
            listener
        ).ignoresSafeArea()
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
