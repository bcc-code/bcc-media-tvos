//
//  ItemImage.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 04/05/2023.
//

import SwiftUI
import CachedAsyncImage

struct ItemImage: View {
    var image: String?

    init(_ image: String?) {
        self.image = image
    }
    
    /// The image host resizes from query parameters, so the URL depends on the laid-out size.
    private func url(for source: String, size: CGSize) -> URL? {
        URL(string: source + "?w=\(Int(size.width))&h=\(Int(size.height))&fit=crop&crop=faces")
    }

    var body: some View {
        GeometryReader { proxy in
            if proxy.size != .zero, let source = image {
                // Computed inline rather than written into `@State` from `.onAppear`. That left the
                // first pass rendering `CachedAsyncImage(url: nil)` — a wasted render and a delayed
                // fetch — and because `onAppear` does not run again, a later size change never
                // produced a correctly-sized URL. The value is a pure function of the source and the
                // laid-out size, so it needed no state at all.
                CachedAsyncImage(url: url(for: source, size: proxy.size)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle().fill(Color.cardBackground)
                    case let .success(image):
                        image.transition(.opacity)
                    case .failure:
                        Image(systemName: "wifi.slash").onAppear {
                            Events.trigger(ErrorOccured(error: "image failed to load"))
                        }
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
            }
        }
    }
}
