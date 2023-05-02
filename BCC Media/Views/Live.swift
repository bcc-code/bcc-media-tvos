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
    var url: URL

    var body: some View {
        PlayerViewController(videoURL: url, title: NSLocalizedString("Live", comment: "")).ignoresSafeArea()
    }
}

struct LiveView: View {
    @State var url: String?

    func load() {
        Task {
            let token = await authenticationProvider.getAccessToken()
            if token != nil {
                var req = URLRequest(url: URL(string: "https://livestreamfunctions.brunstad.tv/api/urls/live")!)
                req.setValue("Bearer " + token!, forHTTPHeaderField: "Authorization")

                let (data, _) = try await URLSession.shared.data(for: req)
                let resp = try JSONDecoder().decode(LiveResponse.self, from: data)
                url = resp.url
            }
        }
    }

    var body: some View {
        NavigationLink {
            if let url = url {
                LivePlayer(url: URL(string: url)!)
            }
        } label: {
            ItemImage("https://brunstadtv.imgix.net/ba20f24f-a3c1-4587-900c-c90bafe63ea7.jpg").overlay(
                Image(systemName: "play.fill").resizable().frame(width: 100, height: 100)
            )
        }.buttonStyle(.card).disabled(url == nil).task { load() }
    }
}
