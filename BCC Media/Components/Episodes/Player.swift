//
//  Player.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 19/04/2023.
//

import SwiftUI

struct EpisodePlayer: View {
    var title: String?
    var playerUrl: URL

    var startFrom: Int

    init(title: String?, playerUrl: URL, startFrom: Int = 0) {
        self.title = title
        self.playerUrl = playerUrl
        self.startFrom = startFrom
    }

    var body: some View {
        PlayerViewController(videoURL: playerUrl, title: title, startFrom: startFrom).ignoresSafeArea()
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
