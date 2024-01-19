//
//  PlayerExtensions.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 22/06/2023.
//

import AVKit

extension AVPlayerItem {
    private func setMediaSelectionGroup(_ language: String, characteristic: AVMediaCharacteristic) async -> Bool {
        do {
            guard let group = try await asset.loadMediaSelectionGroup(for: characteristic) else {
                return false
            }
            let locale = Locale(identifier: language)
            let options = AVMediaSelectionGroup.mediaSelectionOptions(from: group.options, with: locale)
            if let option = options.first {
                select(option, in: group)
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
               let languageCode = selectedOption.extendedLanguageTag
            {
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
