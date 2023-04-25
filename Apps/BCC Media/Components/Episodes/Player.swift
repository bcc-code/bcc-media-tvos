//
//  Player.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 19/04/2023.
//

import SwiftUI
import AVKit

struct PlayerViewController: UIViewControllerRepresentable {
    var videoURL: URL
    var title: String?

    private var player: AVPlayer {
        AVPlayer(url: videoURL)
    }
    
    private func createMetadataItem(for identifier: AVMetadataIdentifier,
                                    value: Any) -> AVMetadataItem {
        let item = AVMutableMetadataItem()
        item.identifier = identifier
        item.value = value as? NSCopying & NSObjectProtocol
        // Specify "und" to indicate an undefined language.
        item.extendedLanguageTag = "und"
        return item.copy() as! AVMetadataItem
    }
    
    func createMetadataItems() -> [AVMetadataItem] {
        let mapping: [AVMetadataIdentifier: Any] = [
            .commonIdentifierTitle: title as Any
        ]
        
        return mapping.compactMap { createMetadataItem(for: $0, value: $1)}
    }

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.title = title
        controller.modalPresentationStyle = .fullScreen
        controller.player = player
        controller.player!.play()
        
        player.currentItem?.externalMetadata = createMetadataItems()

        return controller
    }

    func updateUIViewController(_ playerController: AVPlayerViewController, context: Context) {
    }
}

struct EpisodePlayer: View {
    var title: String?
    var playerUrl: URL

    var body: some View {
        PlayerViewController(videoURL: playerUrl, title: title).ignoresSafeArea()
    }
}
