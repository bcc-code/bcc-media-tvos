//
//  Player.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 19/04/2023.
//

import SwiftUI
import API

struct EpisodePlayer: View {
    @Environment(\.dismiss) var dismiss
 
    var episode: API.GetEpisodeQuery.Data.Episode
    var next: () -> Void

    @State var listener = PlayerListener()
    
    var progress: Bool
    var stateCallback: (PlaybackState) -> Void

    init(episode: API.GetEpisodeQuery.Data.Episode, next: @escaping () -> Void = {}, progress: Bool = true) {
        self.episode = episode
        self.progress = progress
        self.next = next
        self.stateCallback = { state in
            if progress {
                apolloClient.perform(mutation: API.SetEpisodeProgressMutation(id: episode.id, progress: .some(Int(state.time))))
            }
        }
    }

    @State var url: URL? = nil
    @State var options: PlayerOptions? = nil
    @State var loaded = false

    func load() async {
        listener = PlayerListener(stateCallback: stateCallback, endCallback: next, expireCallback: {
            dismiss()
        })
        let data = await apolloClient.getAsync(query: API.GetEpisodeStreamsQuery(id: episode.id), cachePolicy: .fetchIgnoringCacheCompletely)
        url = getPlayerUrl(streams: data!.episode.streams)
        options = .init(
            title: episode.title,
            startFrom: progress ? data!.episode.progress ?? 0 : 0,
            audioLanguage: AppOptions.audioLanguage,
            subtitleLanguage: AppOptions.subtitleLanguage,
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
        
        PlayerControls.setItem(url!, options!, listener)
        loaded = true
    }

    var body: some View {
        Group {
            if loaded {
                VideoPlayerView(fullscreen: .constant(true))
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
