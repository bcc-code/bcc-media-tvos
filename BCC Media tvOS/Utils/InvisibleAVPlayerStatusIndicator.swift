import AVKit
import SwiftUI

struct InvisibleAVPlayerStatusIndicator: View {
    @ObservedObject var controls: PlayerControls
    let identifier: String

    var body: some View {
        Text(identifier)
            .accessibilityIdentifier(identifier)
            .accessibilityLabel(getAccessibilityLabel())
            .frame(width: 0, height: 0)
            .opacity(0)
    }

    private func getAccessibilityLabel() -> String {
        if let _ = controls.error {
            return "Error"
        } else if controls.playing {
            return "Playing"
        } else if controls.loading {
            return "Loading"
        } else {
            return "Idle"
        }
    }
}
