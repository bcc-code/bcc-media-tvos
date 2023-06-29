//
//  Player.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 19/04/2023.
//

import SwiftUI

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
                apolloClient.perform(mutation: API.SetEpisodeProgressMutation(id: episode.id, progress: .some(Int(state.time)))) { _ in
                    print("updated progress")
                }
            }
        }
    }

    @State var url: URL? = nil
    @State var options: PlayerOptions? = nil

    func load() async {
        listener = PlayerListener(stateCallback: stateCallback, endCallback: next, expireCallback: {
            dismiss()
        })
        let data = await apolloClient.getAsync(query: API.GetEpisodeStreamsQuery(id: episode.id), cachePolicy: .fetchIgnoringCacheCompletely)
        url = getPlayerUrl(streams: data!.episode.streams)
        options = .init(
            title: episode.title,
            startFrom: progress ? episode.progress ?? 0 : 0,
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
