//
//  PlayerViewController.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 04/05/2023.
//

import SwiftUI
import AVKit

struct PlayerViewController: UIViewControllerRepresentable {
    var videoURL: URL
    var options: Options
    
    init(_ videoURL: URL, _ options: Options = .init()) {
        self.videoURL = videoURL
        self.options = options
    }
    
    struct Options {
        var startFrom: Int
        var title: String?
        var audioLanguage: String?
        var subtitleLanguage: String?
        
        init(title: String? = nil, startFrom: Int = 0, audioLanguage: String? = nil, subtitleLanguage: String? = nil) {
            self.title = title
            
            self.startFrom = startFrom
            self.subtitleLanguage = subtitleLanguage ?? UserDefaults.standard.string(forKey: "audioLanguage")
            self.audioLanguage = audioLanguage ?? UserDefaults.standard.string(forKey: "subtitleLanguage")
        }
    }

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
}

extension AVPlayerItem {
    private func setMediaSelectionGroup(_ language: String, characteristic: AVMediaCharacteristic) async -> Bool {
        do {
            guard let group = try await asset.loadMediaSelectionGroup(for: characteristic) else {
                return false
            }
            let locale = Locale(identifier: language)
            let options = AVMediaSelectionGroup.mediaSelectionOptions(from: group.options, with: locale)
            if let option = options.first {
                self.select(option, in: group)
                return true
            }
        } catch {
            print(error)
        }
        return false
    }
    
    private func getMediaSelectionGroup(characteristic: AVMediaCharacteristic) async -> String? {
        do {
            if let group = try await asset.loadMediaSelectionGroup(for: characteristic),
                let selectedOption = currentMediaSelection.selectedMediaOption(in: group),
                let languageCode = selectedOption.extendedLanguageTag {
                return languageCode
            }
        } catch {
            print(error)
        }
        return nil
    }
    
    func setAudioLanguage(_ audioLanguage: String) async -> Bool {
        await setMediaSelectionGroup(audioLanguage, characteristic: .audible)
    }

    func setSubtitleLanguage(_ subtitleLanguage: String) async -> Bool {
        await setMediaSelectionGroup(subtitleLanguage, characteristic: .legible)
    }
    
    func getSelectedAudioLanguage() async -> String? {
        await getMediaSelectionGroup(characteristic: .audible)
    }
    
    func getSelectedSubtitleLanguage() async -> String? {
        await getMediaSelectionGroup(characteristic: .legible)
    }
}

