//
//  Player.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 19/04/2023.
//

import API
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
                apolloClient.perform(mutation: API.SetEpisodeProgressMutation(id: episode.id, progress: .some(Int(state.time))))
            }
        }
    }

    @State var loaded = false
    @State var showLanguageSelector = false
    @State var languages: [Language] = []
    @State var urls: StreamUrls? = nil
    @State var query: API.GetEpisodeStreamsQuery.Data? = nil

    func load() async {
        listener = PlayerListener(stateCallback: stateCallback, endCallback: next, expireCallback: {
            dismiss()
        })
        guard let data = await apolloClient.getAsync(query: API.GetEpisodeStreamsQuery(id: episode.id), cachePolicy: .fetchIgnoringCacheCompletely) else {
            return
        }
        query = data
        let streamUrls = StreamUrls(streams: data.episode.streams)
        urls = streamUrls

        if streamUrls.languages.isEmpty {
            // `get(language: nil)` returns the same default `getPlayerUrl` picks — `StreamUrls.init`
            // already called it — so this drops a duplicate computation along with the unwrap.
            guard let url = streamUrls.get(language: nil) else {
                print("no playable stream for episode \(episode.id)")
                dismiss()
                return
            }
            setUrl(url: url)
            return
        }
        // Assigned rather than appended: `languages` is @State, so appending would accumulate if
        // this ever ran twice.
        languages = Language.getAll().filter { streamUrls.languages.contains($0.code) }
        showLanguageSelector = true
    }

    func setUrl(url: URL) {
        guard let q = query else {
            return
        }
        PlayerControls.setItem(url, .init(
            title: episode.title,
            startFrom: progress ? q.episode.progress ?? 0 : 0,
            audioLanguage: AppOptions.audioLanguage,
            subtitleLanguage: AppOptions.subtitleLanguage,
            content: .init(
                title: episode.originalTitle,
                id: episode.id,
                seasonTitle: episode.season?.title,
                seasonId: episode.season?.id,
                showTitle: episode.season?.show.title,
                showId: episode.season?.show.id
            )
        ), listener)
        loaded = true
    }

    func setLanguage(language: String?) {
        showLanguageSelector = false
        guard let url = urls?.get(language: language) else {
            print("no stream for language \(language ?? "original") on episode \(episode.id)")
            dismiss()
            return
        }
        setUrl(url: url)
    }

    var body: some View {
        Group {
            ZStack {
                if loaded {
                    VideoPlayerView(fullscreen: .constant(true))
                }
                if showLanguageSelector {
                    VStack {
                        Text("select_video_language").font(.barlowTitle)
                        Text("video_language_on_screen_graphics").font(.barlowCaption)
                        VStack(alignment: .leading) {
                            Button {
                                setLanguage(language: nil)
                            } label: {
                                Text("original").padding(20).frame(maxWidth: .infinity)
                            }.buttonStyle(.card)
                                // The label is localized; the UI test needs a stable handle to get
                                // past this picker, since the player is not created until a language
                                // is chosen.
                                .accessibilityIdentifier("VideoLanguage-original")
                            ForEach(languages, id: \.code) { lang in
                                Button {
                                    setLanguage(language: lang.code)
                                } label: {
                                    Text(lang.display.capitalizedSentence).padding(20).frame(maxWidth: .infinity)
                                }.buttonStyle(.card)
                            }
                        }.frame(width: 400)
                    }
                }
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
