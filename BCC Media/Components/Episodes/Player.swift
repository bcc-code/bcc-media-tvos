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

    init(episode: API.GetEpisodeQuery.Data.Episode, playerUrl: URL, startFrom: Int = 0) {
        self.episode = episode
        
        self.playerUrl = playerUrl
        self.startFrom = startFrom
    }

    var body: some View {
        PlayerViewController(playerUrl, .init(title: episode.title, startFrom: startFrom, isLive: false, content: .init(
            episodeTitle: episode.title,
            episodeId: episode.id,
            seasonTitle: episode.season?.title,
            seasonId: episode.season?.id,
            showTitle: episode.season?.show.title,
            showId: episode.season?.show.id
        ))).ignoresSafeArea()
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
