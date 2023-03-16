//
// Created by Fredrik Vedvik on 16/03/2023.
//

import Foundation
import SwiftUI
import AVKit

struct LiveResponse: Codable {
    var url: String

    enum CodingKeys: String, CodingKey {
        case url = "url"
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
            let token = try await authenticationProvider.getAccessToken()
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
            Text("Join")
        }.disabled(url == nil).task { load() }
    }
}