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
    
    @State var url: URL? = nil

    func getImg(_ img: String, _ size: CGSize) -> URL? {
        URL(string: img + "?w=\(Int(size.width))&h=\(Int(size.height))&fit=crop&crop=faces")
    }

    var body: some View {
        GeometryReader { proxy in
            if proxy.size != .zero, let img = image {
                CachedAsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Rectangle().fill(cardBackgroundColor)
                    case let .success(image):
                        image.transition(.opacity)
                    case .failure:
                        Image(systemName: "wifi.slash").onAppear {
                            Events.trigger(ErrorOccured(error: "image failed to load"))
                        }
                    @unknown default:
                        EmptyView()
                    }
                }.onAppear {
                    url = getImg(img, proxy.size)
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
            }
        }
    }
}
