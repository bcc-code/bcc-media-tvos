//
// Created by Fredrik Vedvik on 16/03/2023.
//

import AVKit
import Foundation
import SwiftUI

struct LiveResponse: Codable {
    var url: String

    enum CodingKeys: String, CodingKey {
        case url
    }
}

struct LivePlayer: View {
    @State var url: URL?

    func load() {
        Task {
            let token = await authenticationProvider.getAccessToken()
            if token != nil {
                var req = URLRequest(url: URL(string: "https://livestreamfunctions.brunstad.tv/api/urls/live")!)
                req.setValue("Bearer " + token!, forHTTPHeaderField: "Authorization")

                let (data, _) = try await URLSession.shared.data(for: req)
                let resp = try JSONDecoder().decode(LiveResponse.self, from: data)
                url = URL(string: resp.url)!
            }
        }
    }

    var body: some View {
        VStack {
            if let url = url {
                PlayerViewController(url, .init(title: "Live", isLive: true, content: .init(id: "livestream"))).ignoresSafeArea()
            } else {
                ProgressView()
            }
        }.onAppear {
            load()
        }.ignoresSafeArea()
    }
}

extension LivePlayer: Hashable {
    static func == (_: LivePlayer, _: LivePlayer) -> Bool {
        true
    }

    func hash(into _: inout Hasher) {}
}

struct LiveView: View {
    var play: () -> Void

    init(_ play: @escaping () -> Void) {
        self.play = play
    }

    private var columns = [GridItem(.flexible()), GridItem(.flexible())]

    @FocusState var isFocused

    var body: some View {
        VStack(alignment: .leading) {
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
            CalendarDay()
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
