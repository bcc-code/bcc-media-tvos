//
// Created by Fredrik Vedvik on 16/03/2023.
//

import AVKit
import Foundation
import SwiftUI
import FeatureFlags

struct LiveView: View {
    var play: () -> Void

    init(_ play: @escaping () -> Void) {
        self.play = play
    }

    private var columns = [GridItem(.flexible()), GridItem(.flexible())]

    @FocusState var isFocused

    var body: some View {
        VStack(alignment: .leading) {
            if !FeatureFlags.has("force-bcc-live") {
                HStack(alignment: .top) {
                    Button {
                        play()
                    } label: {
                        Image(uiImage: UIImage(named: "Live.png")!)
                    }
                    .buttonStyle(SectionItemButton(focused: isFocused))
                    .focused($isFocused)
                    .accessibilityLabel(Text("common_live"))
                    VStack {
                        Text("common_live").font(.barlowTitle).bold()
                    }
                    Spacer()
                }
            }
            if FeatureFlags.has("link-to-bcc-live") {
                Text("go_to_bcc_live_app")
            } else {
                CalendarDay()
            }
        }
        .onAppear {
            Events.page("live")
        }
    }
}

struct LiveView_Previews: PreviewProvider {
    static var previews: some View {
        LiveView {}
    }
}
