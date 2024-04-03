//
//  PlayerOptions.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 22/06/2023.
//

import Foundation

struct PlayerOptions {
    var startFrom: Int
    var title: String?
    var audioLanguage: String?
    var subtitleLanguage: String?

    var isLive: Bool

    var content: Content
    struct Content {
        var title: String?
        var id: String?
        var seasonTitle: String?
        var seasonId: String?
        var showTitle: String?
        var showId: String?
    }

    init(
        title: String? = nil,
        startFrom: Int = 0,
        audioLanguage: String? = nil,
        subtitleLanguage: String? = nil,
        isLive: Bool = false,
        content: Content = .init()
    ) {
        self.title = title

        self.startFrom = startFrom
        self.subtitleLanguage = subtitleLanguage ?? AppOptions.standard.subtitleLanguage
        self.audioLanguage = audioLanguage ?? AppOptions.standard.audioLanguage

        self.isLive = isLive

        self.content = content
    }
}
