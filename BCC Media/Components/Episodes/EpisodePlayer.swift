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

    init(_ episode: API.GetEpisodeQuery.Data.Episode) {
        self.episode = episode

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
    
    func urlFactory(_ episodeId: String) -> () async -> URL {
        func getUrl() async -> URL {
            let data = await apolloClient.getAsync(query: API.GetEpisodeStreamsQuery(id: episode.id))
            let playerUrl = getPlayerUrl(streams: data!.episode.streams)
            return playerUrl!
        }
        return getUrl
    }
    
    func getPlayerItem(_ episode: API.GetEpisodeQuery.Data.Episode) -> VideoPlayerItem {
        let hasNext = episode.next.count > 0
        
        return VideoPlayerItem(
            url: urlFactory(episode.id),
            options: getPlayerOptions(episode),
            nextFactory: hasNext ? nextFactory(episode.next[0].id) : nil
        )
    }
    
    func nextFactory(_ episodeId: String) -> () async -> VideoPlayerItem {
        func getNext() async -> VideoPlayerItem {
            let data = await apolloClient.getAsync(query: API.GetEpisodeQuery(id: episodeId))
            return getPlayerItem(data!.episode)
        }
        return getNext
    }
    
    var body: some View {
        VideoPlayer(
            getPlayerItem(episode)
        ).ignoresSafeArea()
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
