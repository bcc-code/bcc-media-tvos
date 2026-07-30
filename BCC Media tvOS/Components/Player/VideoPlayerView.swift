//
//  VideoPlayer.swift
//  BCC Live
//
//  Created by Fredrik Vedvik on 19/12/2023.
//

import AVKit
import NpawPlugin
import SwiftUI

struct PlaybackState {
    var time: Double
}

extension NpawPluginProvider {
    static func setup() {
        let options = AnalyticsOptions()
        options.appName = "bccm-tvos"
        options.userName = AppOptions.user.anonymousId
        options.contentCustomDimension1 = Events.sessionId?.stringValue
        options.contentCustomDimension2 = AppOptions.user.ageGroup
        options.parseManifest = true
        options.autoDetectBackground = true
        options.userObfuscateIp = true
        options.appReleaseVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        initialize(accountCode: AppOptions.npaw.accountCode ?? "", analyticsOptions: options, logLevel: .info)
    }
}

/// Playback state, as exposed to SwiftUI and to the `CurrentPlayerStatus` accessibility probe the
/// UI test reads. The raw value *is* the accessibility label, so there is no mapping to keep in
/// sync — the `if error / if playing / if loading` chain this replaces is what let an inverted
/// boolean surface as a wrong label.
enum PlaybackStatus: String {
    case idle = "Idle"
    case loading = "Loading"
    case playing = "Playing"
    case error = "Error"
}

class PlayerControls: ObservableObject {
    var player = AVPlayer()
    var currentUrl: URL?
    
    var adapter: NpawPlugin.VideoAdapter?
    
    @Published private(set) var status: PlaybackStatus = .idle
    @Published private(set) var error: Error?
    
    private var listener: PlayerListener?
    
    var observers: [NSKeyValueObservation] = []
    var currentItemObservers: [NSKeyValueObservation] = []
    
    var expiresAt: Date?

    var timer: Timer?
    
    init(player: AVPlayer = AVPlayer()) {
        self.player = player
        
        observers = [
            // `timeControlStatus` already distinguishes playing / buffering / paused, which is what
            // the two booleans here were trying to encode — one of them against the wrong case.
            // `\.status` is no longer observed: readiness shows up as `.waitingToPlayAtSpecifiedRate`
            // and failure as `player.error`.
            player.observe(\.timeControlStatus, options: [.new, .initial]) { [weak self] _, _ in
                self?.publishStatus()
            },
            player.observe(\.error, options: [.new]) { [weak self] player, _ in
                debugPrint("bccm: error occured: \(player.error?.localizedDescription ?? "nil")")
                self?.setError(player.error)
            },
        ]
    }

    /// Errors arrive from both `AVPlayer` and the current `AVPlayerItem`, so both route through here
    /// and the published state is written in exactly one place.
    func setError(_ error: Error?) {
        onMain { [weak self] in
            self?.error = error
            self?.recomputeStatus()
        }
    }

    private func publishStatus() {
        onMain { [weak self] in self?.recomputeStatus() }
    }

    /// Main thread only — call via `publishStatus()` / `setError(_:)`.
    private func recomputeStatus() {
        if error != nil {
            status = .error
            return
        }
        switch player.timeControlStatus {
        case .playing:
            status = .playing
        // Only reachable once `play()` has been called, so this is buffering, not pre-roll.
        case .waitingToPlayAtSpecifiedRate:
            status = .loading
        case .paused:
            status = .idle
        @unknown default:
            status = .idle
        }
    }

    /// `@Published` writes have to land on the main thread, and KVO delivers on whichever thread
    /// changed the value. Same shape as `FeatureFlagsClient.refreshToggles`.
    private func onMain(_ work: @escaping () -> Void) {
        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.async(execute: work)
        }
    }
    
    static func setItem(_ videoURL: URL, _ options: PlayerOptions = .init(), _ listener: PlayerListener = PlayerListener { _ in }) {
        let playerItem = AVPlayerItem(url: videoURL)
        current.setError(nil)
        current.currentItemObservers = [
            playerItem.observe(\.error, options: [.new]) { item, _ in
                debugPrint("bccc: playeritem error")
                current.setError(item.error)
            },
        ]
        current.player.replaceCurrentItem(with: playerItem)
        current.player.currentItem?.externalMetadata = createMetadataItems(options)
        if NpawPluginProvider.shared?.accountCode != "" {
            current.adapter?.destroy()

            let videoOptions = VideoOptions()

            let c = options.content
            videoOptions.contentId = c.id
            videoOptions.contentTitle = c.title
            videoOptions.contentTvShow = c.showId
            videoOptions.contentSeason = c.seasonId
            videoOptions.contentResource = videoURL.absoluteString
            videoOptions.contentLanguage = Language.toThreeLetterLanguageCode(languageCode: options.audioLanguage)
            videoOptions.contentSubtitles = Language.toThreeLetterLanguageCode(languageCode: options.subtitleLanguage)
            videoOptions.contentTransactionCode = UUID().uuidString
            
            current.adapter = NpawPluginProvider.shared!.videoBuilder()
                .setPlayerAdapter(playerAdapter: AVPlayerAdapter(player: player))
                .setOptions(options: videoOptions)
                .build()
        }
        
        if options.startFrom != 0 {
            current.player.seek(to: CMTimeMakeWithSeconds(Double(options.startFrom), preferredTimescale: 100))
        }
        
        NotificationCenter.default.addObserver(
            listener,
            selector: #selector(listener.playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: current.player.currentItem
        )

        DispatchQueue.main.async {
            self.current.timer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { _ in
                listener.stateCallback(PlaybackState(time: player.currentTime().seconds))
                if expired() {
                    listener.onExpire()
                }
            }
        }
        
        Task {
            let l = options.audioLanguage ?? "no"
            if await current.player.currentItem!.setAudioLanguage(l) {
                print("Successfully set initial audio language to " + l)
            }
        }
        Task {
            let l = options.subtitleLanguage ?? "no"
            if await current.player.currentItem!.setSubtitleLanguage(l) {
                print("Successfully set initial subtitle language to " + l)
            }
        }
        
        current.expiresAt = Calendar.current.date(byAdding: .hour, value: 5, to: .now)

        current.listener = listener
    }
    
    private static func createMetadataItem(for identifier: AVMetadataIdentifier,
                                           value: Any) -> AVMetadataItem
    {
        let item = AVMutableMetadataItem()
        item.identifier = identifier
        item.value = value as? NSCopying & NSObjectProtocol
        // Specify "und" to indicate an undefined language.
        item.extendedLanguageTag = "und"
        return item.copy() as! AVMetadataItem
    }
    
    private static func createMetadataItems(_ options: PlayerOptions) -> [AVMetadataItem] {
        let mapping: [AVMetadataIdentifier: Any] = [
            .commonIdentifierTitle: options.title as Any,
        ]

        return mapping.compactMap { createMetadataItem(for: $0, value: $1) }
    }
    
    static var current = PlayerControls()
    
    static var player: AVPlayer {
        current.player
    }
    
    static var adapter: NpawPlugin.VideoAdapter? {
        current.adapter
    }
    
    static func mute() {
        player.isMuted = true
    }
    
    static func unmute() {
        player.isMuted = false
    }
    
    static func stop() {
        player.pause()
        player.replaceCurrentItem(with: nil)
        adapter?.destroy()
        current.timer?.invalidate()
    }
    
    static func expired() -> Bool {
        current.expiresAt != nil && current.expiresAt! < .now
    }
    
    static func triggerAnalyticsEvent() {
        if let options = adapter?.options {
            guard let videoId = options.contentId else { return }
            guard let referenceId = options.contentTransactionCode else { return }
            
            Events.trigger(VideoPlayed(videoId: videoId, referenceId: referenceId))
        }
    }
}

struct VideoPlayerControllerView: UIViewControllerRepresentable {
    func makeUIViewController(context _: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        
        controller.player = PlayerControls.current.player
        controller.speeds = [
            AVPlaybackSpeed(rate: 0.75, localizedName: "0.75x"),
            AVPlaybackSpeed(rate: 1.0, localizedName: "1.0x"),
            AVPlaybackSpeed(rate: 1.5, localizedName: "1.5x"),
            AVPlaybackSpeed(rate: 1.75, localizedName: "1.75x"),
            AVPlaybackSpeed(rate: 2.0, localizedName: "2.0x"),
        ]
        
        return controller
    }
    
    func updateUIViewController(_ _: AVPlayerViewController, context _: Context) {}
}

struct VideoPlayerView: View {
    @Binding var fullscreen: Bool
    
    var body: some View {
        ZStack {
            VideoPlayerControllerView().ignoresSafeArea()
                .onChange(of: fullscreen) { v in
                    if v {
                        PlayerControls.unmute()
                    } else {
                        PlayerControls.mute()
                    }
                }.onAppear {
                    PlayerControls.player.play()
                    PlayerControls.triggerAnalyticsEvent()
                }.onDisappear {
                    PlayerControls.stop()
                }
            InvisibleAVPlayerStatusIndicator(controls: PlayerControls.current, identifier: "CurrentPlayerStatus")
        }
    }
}
