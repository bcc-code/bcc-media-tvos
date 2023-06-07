//
//  Player.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 07/06/2023.
//

import Foundation
import YouboraLib
import YouboraAVPlayerAdapter

extension YBPlugin {
    convenience init(_ options: PlayerOptions, _ player: AVPlayer) {
        let opts = YBOptions()
        opts.enabled = AppOptions.npaw.accountCode != nil
        opts.accountCode = AppOptions.npaw.accountCode
        opts.username = AppOptions.user.anonymousId
        opts.appName = AppOptions.standard.name

        let c = options.content
        opts.contentId = c.id
        opts.contentTitle = options.title
        opts.contentTvShow = c.showId
        opts.contentIsLive = NSNumber(value: options.isLive)
        opts.contentSeason = c.seasonId != nil && c.seasonTitle != nil ? "\(c.seasonId!) - \(c.seasonTitle!)" : nil
        opts.program = c.showTitle ?? options.title
        opts.contentEpisodeTitle = c.episodeTitle

        opts.contentCustomDimension2 = AppOptions.user.ageGroup

        self.init(options: opts)

        adapter = YBAVPlayerAdapterSwiftTranformer.transform(from: YBAVPlayerAdapter(player: player))
    }
}

struct PlayerOptions {
    var startFrom: Int
    var title: String?
    var audioLanguage: String?
    var subtitleLanguage: String?

    var isLive: Bool

    var content: PlayerContentOptions
    
    init(
        title: String? = nil,
        startFrom: Int = 0,
        audioLanguage: String? = nil,
        subtitleLanguage: String? = nil,
        isLive: Bool = false,
        content: PlayerContentOptions = .init()
    ) {
        self.title = title

        self.startFrom = startFrom
        self.subtitleLanguage = subtitleLanguage ?? AppOptions.standard.subtitleLanguage
        self.audioLanguage = audioLanguage ?? AppOptions.standard.audioLanguage

        self.isLive = isLive

        self.content = content
    }
}

struct PlayerContentOptions {
    var episodeTitle: String?
    var id: String?
    var seasonTitle: String?
    var seasonId: String?
    var showTitle: String?
    var showId: String?
}

struct PlaybackState {
    var time: Double
}

struct PlaybackListener {
    var stateCallback: (PlaybackState) -> Void

    init(stateCallback: @escaping (PlaybackState) -> Void) {
        self.stateCallback = stateCallback
    }

    func onStateUpdate(state: PlaybackState) {
        stateCallback(state)
    }
}

class PlayerCoordinator {
    var timer: Timer?
}
