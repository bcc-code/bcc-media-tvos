//
//  YouboraPlugin.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 22/06/2023.
//

import YouboraAVPlayerAdapter
import YouboraLib

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
