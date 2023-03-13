//
// Created by Fredrik Vedvik on 13/03/2023.
//

import SwiftUI
import AVKit

struct PlayerViewController: UIViewControllerRepresentable {
    var videoURL: URL

    private var player: AVPlayer {
        AVPlayer(url: videoURL)
    }

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.modalPresentationStyle = .fullScreen
        controller.player = player
        controller.showsPlaybackControls = true
        controller.player!.play()

        return controller
    }

    func updateUIViewController(_ playerController: AVPlayerViewController, context: Context) {}
}

struct EpisodeViewer: View {
    @State var episodeId: String
    @State private var playerUrl: URL?

    var body: some View {
        VStack {
            if let url = playerUrl {
                PlayerViewController(videoURL: url)
            } else {
                ProgressView()
            }
        }.task {
            apolloClient.fetch(query: API.GetEpisodeQuery(id: episodeId)) { result in
                switch result{
                case let .success(res):
                    if let streams = res.data?.episode.streams {
                        if let stream = streams.first(where: { $0.type == API.StreamType.hlsCmaf }) {
                            playerUrl = URL(string: stream.url)
                        }
                    }
                case .failure:
                    print("FAILURE")

                }
            }
        }
    }
}

struct EpisodeViewer_Previews: PreviewProvider {
    static var previews: some View {
        EpisodeViewer(episodeId: "1768")
    }
}
