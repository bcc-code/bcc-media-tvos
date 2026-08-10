import AVKit
import SwiftUI

struct InvisibleAVPlayerStatusIndicator: View {
    @ObservedObject var controls: PlayerControls
    let identifier: String

    var body: some View {
        Text(identifier)
            .accessibilityIdentifier(identifier)
            .accessibilityLabel(controls.status.rawValue)
            .frame(width: 0, height: 0)
            .opacity(0)
    }
}
