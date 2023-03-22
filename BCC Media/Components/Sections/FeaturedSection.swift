//
// Created by Fredrik Vedvik on 21/03/2023.
//

import SwiftUI

struct FeaturedSection: View {
    var title: String?
    var items: [Item]

    @State private var index = 0

    var body: some View {
        HStack {
            TabView(selection: $index) {
                ForEach((0..<items.count), id: \.self) { index in
                    VStack {
                        NavigationLink {
                            EpisodeViewer(episodeId: items[index].id)
                        } label: {
                            ItemImage(image: items[index].image)
                                    .mask(LinearGradient(gradient: Gradient(colors: [.black, .black, .black, .clear]), startPoint: .top, endPoint: .bottom))
                        }
                                .buttonStyle(.card)
                                .overlay(Text(items[index].title).font(.title3).padding(10), alignment: .bottom)
                    }
                            .padding(100)
                }
            }
                    .tabViewStyle(.page(indexDisplayMode: .never))
        }
                .padding(-100)
                .frame(height: 800)
    }
}

struct FeaturedSection_Preview: PreviewProvider {
    static var previews: some View {
        FeaturedSection(title: "Featured", items: [
            Item(id: "10", title: "Another Item", image: "https://brunstadtv.imgix.net/92a64b64-1f82-42c2-85f2-8a7ff39b1f90.jpg")
        ])
    }
}
