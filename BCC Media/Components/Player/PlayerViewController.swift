//
//  PlayerViewController.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 04/05/2023.
//

import AVKit
import SwiftUI
import YouboraAVPlayerAdapter
import YouboraLib

struct PlaybackState {
    var time: Double
}

struct PlayerViewController: UIViewControllerRepresentable {
    var videoURL: URL
    var options: PlayerOptions

    private var player: AVPlayer
    private var plugin: YBPlugin

    private var coordinator: Coordinator

    private var listener: PlayerListener

    init(_ videoURL: URL, _ options: PlayerOptions = .init(), _ listener: PlayerListener = PlayerListener { _ in }) {
        self.videoURL = videoURL
        self.options = options
        player = AVPlayer(url: videoURL)

        plugin = YBPlugin(options, player)

        self.listener = listener

        coordinator = Coordinator()
        coordinator.timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [self] _ in
            listener.onStateUpdate(state: self.getState())
        }
    }

    class Coordinator {
        var timer: Timer?
    }

    func makeCoordinator() -> Coordinator {
        coordinator
    }

    func getState() -> PlaybackState {
        PlaybackState(time: player.currentTime().seconds)
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

        NotificationCenter.default.addObserver(
            listener,
            selector: #selector(listener.playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: controller.player!.currentItem
        )

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

    static func dismantleUIViewController(_: AVPlayerViewController, coordinator: Coordinator) {
        coordinator.timer?.invalidate()
    }
}

