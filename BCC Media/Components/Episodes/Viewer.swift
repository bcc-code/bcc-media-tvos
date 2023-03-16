//
// Created by Fredrik Vedvik on 13/03/2023.
//

import SwiftUI
import AVKit

struct PlayerViewController: UIViewControllerRepresentable {
    var videoURL: URL
    var title: String?

    private var player: AVPlayer {
        AVPlayer(url: videoURL)
    }

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.title = title
        controller.modalPresentationStyle = .fullScreen
        controller.player = player
        controller.player!.play()

        return controller
    }

    func updateUIViewController(_ playerController: AVPlayerViewController, context: Context) {
    }
}

struct EpisodeViewer: View {
    @State var episodeId: String
    @State private var playerUrl: URL?
    @State private var episode: API.GetEpisodeQuery.Data.Episode?

    func getPlayerUrl() -> URL? {
        if let streams = episode?.streams {
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
                return URL(string: stream.url)
            }
        }
        return nil
    }

    var body: some View {
        if let e = episode, let url = getPlayerUrl() {
            PlayerViewController(videoURL: url, title: e.title).ignoresSafeArea()
        } else {
            ProgressView().task {
                apolloClient.fetch(query: API.GetEpisodeQuery(id: episodeId)) { result in
                    switch result {
                    case let .success(res):
                        if let e = res.data?.episode {
                            episode = e
                        }
                    case .failure:
                        print("FAILURE")

                    }
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
