//
//  Theme.swift
//  BCC Media
//

import SwiftUI

/// The app's palette.
///
/// These were three file-scope computed `var`s in `ContentView.swift`, so every access constructed a
/// new `Color` and none of them were namespaced. Kept as an extension rather than moved to the asset
/// catalog because the app pins `.preferredColorScheme(.dark)`, so the light/dark variants an asset
/// colour would buy have nothing to vary.
extension Color {
    /// The window background.
    static let appBackground = Color(red: 13 / 255, green: 22 / 255, blue: 35 / 255)

    /// Fill behind cards, and the placeholder shown while an image loads.
    static let cardBackground = Color(red: 29 / 255, green: 40 / 255, blue: 56 / 255)

    /// Fill for the card representing the item currently being viewed.
    static let cardActiveBackground = Color(red: 58 / 255, green: 80 / 255, blue: 112 / 255)
}
