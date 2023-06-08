//
//  VideoPlayer.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 07/06/2023.
//

import SwiftUI
import AVKit

struct VideoPlayerCoordinator {
    
}

struct VideoPlayerItem {
    var url: () async -> URL
    var options: PlayerOptions = .init()
    
    var nextFactory: (() async -> VideoPlayerItem)? = nil
    
    func toPlayerItem() async -> AVPlayerItem {
        let item = AVPlayerItem(url: await url())
        
        item.externalMetadata = Self.createMetadataItems(for: options)
        
        return item
    }
    
    static private func createMetadataItems(for metadata: PlayerOptions) -> [AVMetadataItem] {
        let mapping: [AVMetadataIdentifier: Any] = [
            .commonIdentifierTitle: metadata.title
        ]
        return mapping.compactMap { createMetadataItem(for:$0, value:$1) }
    }


    static private func createMetadataItem(for identifier: AVMetadataIdentifier,
                                    value: Any) -> AVMetadataItem {
        let item = AVMutableMetadataItem()
        item.identifier = identifier
        item.value = value as? NSCopying & NSObjectProtocol
        // Specify "und" to indicate an undefined language.
        item.extendedLanguageTag = "und"
        return item.copy() as! AVMetadataItem
    }

}

struct VideoPlayerController: UIViewControllerRepresentable {
    var player: AVPlayer
    
    init(_ player: AVPlayer) {
        self.player = player
    }
    
    private func playerDidFinishPlaying(note: NSNotification) {
        
    }
    
    func makeCoordinator() -> VideoPlayerCoordinator {
        VideoPlayerCoordinator()
    }
    
    func makeUIViewController(context _: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        
    }
    
    static func dismantleUIViewController(_ uiViewController: VideoPlayerController, coordinator: VideoPlayerCoordinator) {
        
    }
}

private class Observer {
    private var cb: (() -> Void)? = nil

    public func setCallback(_ cb: @escaping () -> Void) {
        self.cb = cb
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        cb?()
    }
}

struct VideoPlayer: View {
    private var player = AVQueuePlayer()
    
    private var observer = Observer()
    
    var initialItem: VideoPlayerItem
    
    @State var item: VideoPlayerItem? = nil
    
    init(_ item: VideoPlayerItem) {
        initialItem = item
    }
    
    func load() async {
        guard let item = item else {
            return
        }
        player.insert(await item.toPlayerItem(), after: nil)
        await player.seek(to: CMTimeMakeWithSeconds(Double(item.options.startFrom), preferredTimescale: 100))
        player.play()
        
        observer.setCallback {
            Task { @MainActor in
                await next()
            }
        }
        
        NotificationCenter.default
            .addObserver(self.observer,
                         selector: #selector(self.observer.playerDidFinishPlaying),
                         name: .AVPlayerItemDidPlayToEndTime,
                         object: player.currentItem)
    }
    
    func next() async {
        if let f = item?.nextFactory {
            self.item = await f()
            await load()
        }
    }
    
    var body: some View {
        VideoPlayerController(player).task {
            await load()
        }.onDisappear {
            print("Unloading video-player")
        }.onAppear {
            item = initialItem
        }
    }
}
