//
//  Player.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 19/04/2023.
//

import AVKit
import SwiftUI

struct PlayerViewController: UIViewControllerRepresentable {
    var videoURL: URL
    var title: String?
    var startFrom: Int

    private var player: AVPlayer {
        AVPlayer(url: videoURL)
    }

    private func createMetadataItem(for identifier: AVMetadataIdentifier,
                                    value: Any) -> AVMetadataItem
    {
        let item = AVMutableMetadataItem()
        item.identifier = identifier
        item.value = value as? NSCopying & NSObjectProtocol
        // Specify "und" to indicate an undefined language.
        item.extendedLanguageTag = "und"
        return item.copy() as! AVMetadataItem
    }

    func createMetadataItems() -> [AVMetadataItem] {
        let mapping: [AVMetadataIdentifier: Any] = [
            .commonIdentifierTitle: title as Any,
        ]

        return mapping.compactMap { createMetadataItem(for: $0, value: $1) }
    }

    func makeUIViewController(context _: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.title = title
        controller.modalPresentationStyle = .fullScreen
        controller.player = player
        if startFrom != 0 {
            controller.player!.seek(to: CMTimeMakeWithSeconds(Double(startFrom), preferredTimescale: 100))
        }
        controller.player!.play()

        player.currentItem?.externalMetadata = createMetadataItems()

        return controller
    }

    func updateUIViewController(_: AVPlayerViewController, context _: Context) {}
}

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
