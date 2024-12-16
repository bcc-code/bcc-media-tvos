//
// Created by Fredrik Vedvik on 16/03/2023.
//

import AVKit
import Foundation
import SwiftUI
import FeatureFlags

struct LiveView: View {
    @EnvironmentObject var flags: Flags
    
    var play: () -> Void

    init(_ play: @escaping () -> Void) {
        self.play = play
    }

    private var columns = [GridItem(.flexible()), GridItem(.flexible())]

    @FocusState var isFocused
    
    @FocusState var newAppFocused

    var body: some View {
        VStack(alignment: .leading) {
            if !flags.forceBccLive {
                HStack(alignment: .top) {
                    Button {
                        play()
                    } label: {
                        Image(uiImage: UIImage(named: "Live.png")!).frame(width: 1280/2, height: 720/2)
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
            CalendarDay()
        }.frame(width: 1280)
        .onAppear {
            Events.page("live")
        }
    }
}

func getFlags() -> Flags {
    let flags = Flags();
//    flags.forceBccLive = true;
    return flags
}

struct LiveView_Previews: PreviewProvider {
    static var previews: some View {
        LiveView {}.environmentObject(getFlags())
    }
}
