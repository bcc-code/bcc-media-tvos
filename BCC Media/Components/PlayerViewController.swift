//
//  PlayerViewController.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 04/05/2023.
//

import AVKit
import SwiftUI
import YouboraLib

struct PlayerViewController: UIViewControllerRepresentable {
    var options: PlayerOptions

    static var player = AVQueuePlayer(items: [])
    static func add(_ url: URL) {
        player.insert(AVPlayerItem(url: url), after: nil)
    }
    private var plugin: YBPlugin
    
    private var coordinator: PlayerCoordinator

    init(_ url: URL, _ options: PlayerOptions = .init(), _ listener: PlaybackListener = PlaybackListener { _ in }, nextOptions: PlayerOptions? = nil) {
        self.options = options
        
        PlayerViewController.player.insert(AVPlayerItem(url: url), after: nil)

        plugin = YBPlugin(options, PlayerViewController.player)

        coordinator = PlayerCoordinator()
        coordinator.timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [self] _ in
            listener.onStateUpdate(state: self.getState())
        }
    }
    
    private var player: AVQueuePlayer {
        PlayerViewController.player
    }

    func makeCoordinator() -> Coordinator {
        coordinator
    }

    func getState() -> PlaybackState {
        PlaybackState(time: PlayerViewController.player.currentTime().seconds)
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
            .commonIdentifierTitle: options.title as Any,
        ]

        return mapping.compactMap { createMetadataItem(for: $0, value: $1) }
    }

    func makeUIViewController(context _: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.title = options.title
        controller.modalPresentationStyle = .fullScreen
        controller.player = player
        if options.startFrom != 0 {
            controller.player!.seek(to: CMTimeMakeWithSeconds(Double(options.startFrom), preferredTimescale: 100))
        }
        controller.player!.play()

        if let item = controller.player!.currentItem {
            item.externalMetadata = createMetadataItems()
            Task {
                if let l = options.audioLanguage, await item.setAudioLanguage(l) {
                    print("Successfully set initial audio language")
                }
            }
            Task {
                if let l = options.subtitleLanguage, await item.setSubtitleLanguage(l) {
                    print("Successfully set initial subtitle language")
                }
            }
        }

        return controller
    }

    func updateUIViewController(_: AVPlayerViewController, context _: Context) {}

    static func dismantleUIViewController(_: AVPlayerViewController, coordinator: PlayerCoordinator) {
        coordinator.timer?.invalidate()
        
        player.removeAllItems()
    }
}

