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
            if let u = url {
                PlayerViewController(videoURL: u, title: NSLocalizedString("common_live", comment: ""), startFrom: 0).ignoresSafeArea()
            } else {
                ProgressView()
            }
        }.onAppear {
            load()
        }.ignoresSafeArea()
    }
}

struct LiveView: View {
    var columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(uiImage: UIImage(named: "Live.png")!)
                NavigationLink {
                    LivePlayer()
                } label: {
                    Text("live_play")
                }
                Spacer()
            }
            ScrollView(.horizontal) {
                LazyHStack(alignment: .top) {
                    ForEach([0, 1, 2, 3, 4, 5], id: \.self) {index in
                        VStack {    
                            Rectangle().foregroundColor(cardBackgroundColor).frame(width: 600, height: 300)
                        }
                    }
                }
            }
        }
    }
}

struct LiveView_Previews: PreviewProvider {
    static var previews: some View {
        LiveView()
    }
}
