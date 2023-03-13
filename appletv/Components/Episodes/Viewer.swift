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

    func updateUIViewController(_ playerController: AVPlayerViewController, context: Context) {
    }
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
        }
                .task {
                    apolloClient.fetch(query: API.GetEpisodeQuery(id: episodeId)) { result in
                        switch result {
                        case let .success(res):
                            if let streams = res.data?.episode.streams {
                                let types = [API.StreamType.hlsTs, API.StreamType.hlsCmaf, API.StreamType.dash]
                                var index = 0
                                var stream = streams.first(where: { $0.type == types[index] })
                                while stream == nil && (types.count - 1) > index {
                                    index += 1
                                    stream = streams.first(where: { $0.type == types[index] })
                                }
                                if stream == nil {
                                    stream = streams.first
                                }
                                if let stream = stream {
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
