//
//  LivePlayer.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 29/06/2023.
//

import SwiftUI

struct LiveResponse: Codable {
    var url: String

    enum CodingKeys: String, CodingKey {
        case url
    }
}

struct LivePlayer: View {
    @Environment(\.dismiss) var dismiss
    
    @State var loaded = false
    
    @State var url: URL?
    
    @State var playerListener: PlayerListener = PlayerListener()

    func load() {
        Task {
            playerListener = PlayerListener(expireCallback: {
                dismiss()
            })
            let token = await authenticationProvider.getAccessToken()
            if token != nil {
                var req = URLRequest(url: URL(string: "https://livestreamfunctions.brunstad.tv/api/urls/live")!)
                req.setValue("Bearer " + token!, forHTTPHeaderField: "Authorization")

                let (data, _) = try await URLSession.shared.data(for: req)
                let resp = try JSONDecoder().decode(LiveResponse.self, from: data)
                url = URL(string: resp.url)!
                
                PlayerControls.setItem(url!, .init(title: "Live", audioLanguage: AppOptions.audioLanguage, subtitleLanguage: AppOptions.subtitleLanguage, isLive: true, content: .init(id: "livestream")), playerListener)
            }
            loaded = true
        }
    }

    var body: some View {
        VStack {
            if loaded {
                VideoPlayerView(fullscreen: .constant(true))
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
