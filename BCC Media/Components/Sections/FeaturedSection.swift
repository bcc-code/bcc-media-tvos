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
                ForEach(items, id: \.id) { item in
                    VStack {
                        NavigationLink {
                            EpisodeViewer(episodeId: item.id)
                        } label: {
                            ItemImage(image: item.image)
//                                    .mask(LinearGradient(gradient: Gradient(colors: [.black, .black, .black, .clear]), startPoint: .top, endPoint: .bottom))
                        }
                                .buttonStyle(.card)
//                                .overlay(VStack (alignment: .leading){
//                                    Text(item.title).font(.title3).padding(10)
////                                    if item.description != "" {
////                                        Text(item.description).font(.subheadline).padding(10)
////                                    }
//                                }, alignment: .bottomLeading)
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
            Item(id: "10", title: "Another Item", description: "description", image: "https://brunstadtv.imgix.net/92a64b64-1f82-42c2-85f2-8a7ff39b1f90.jpg")
        ])
    }
}
