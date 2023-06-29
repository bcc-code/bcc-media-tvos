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
    
    private var expiresAt: Date?

    private var listener: PlayerListener
    
    public var plugin: YBPlugin

    init(_ videoURL: URL, _ options: PlayerOptions = .init(), _ listener: PlayerListener = PlayerListener { _ in }) {
        self.videoURL = videoURL
        self.options = options
        player = AVPlayer(url: videoURL)
        plugin = YBPlugin(options, player)
        
        self.expiresAt = Calendar.current.date(byAdding: .hour, value: 5, to: .now)

        self.listener = listener
    }

    final class Coordinator {
        let parent: PlayerViewController
        let timer: Timer
        
        init(_ parent: PlayerViewController) {
            self.parent = parent
            
            timer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { _ in
                parent.listener.stateCallback(parent.getState())
                if parent.expired() {
                    parent.listener.onExpire()
                }
            }
        }
        
        deinit {
            timer.invalidate()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func getState() -> PlaybackState {
        PlaybackState(time: player.currentTime().seconds)
    }
    
    func expired() -> Bool {
        expiresAt != nil && expiresAt! < .now
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

    static func dismantleUIViewController(_: PlayerViewController, coordinator: Coordinator) {
        coordinator.parent.plugin.fireStop()
        
        print("DISMANTLED VIEW")
    }
}


class PlayerViewControllerImplementation: AVPlayerViewController {
    weak var coordinator: PlayerViewController.Coordinator?
    
    
}
