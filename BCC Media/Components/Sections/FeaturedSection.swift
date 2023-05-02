//
// Created by Fredrik Vedvik on 21/03/2023.
//

import SwiftUI

struct FeaturedButton: ButtonStyle {
    let focused: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.zero)
            .scaleEffect(configuration.isPressed || focused ? 1.02 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed || focused)
    }
}

struct FeaturedCard: View {
    var item: Item

    @FocusState var isFocused: Bool

    var body: some View {
        NavigationLink {
            EpisodeViewer(episodeId: item.id)
        } label: {
            ItemImage(item.image)
                .mask(LinearGradient(gradient: Gradient(colors: [.black, .black, .clear]), startPoint: .top, endPoint: .bottom))
                .cornerRadius(10)
                .padding(.zero)
                .overlay(
                    VStack(alignment: .leading, spacing: 20) {
                        Text(item.title).font(.title3)

                        if item.description != "" {
                            Text(item.description).font(.caption2).foregroundColor(.gray)
                        }
                    }.padding(20).frame(maxWidth: 1000),

                    alignment: .bottomLeading
                )
        }
        .buttonStyle(FeaturedButton(focused: isFocused))
        .padding(0)
        .focused($isFocused)
    }
}

struct FeaturedSection: View {
    var title: String?
    var items: [Item]

    var body: some View {
        TabView {
            ForEach(items.indices, id: \.self) { index in
                FeaturedCard(item: items[index])
            }.padding(100)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 800).padding(-100)
    }
}

struct FeaturedSection_Preview: PreviewProvider {
    static var previews: some View {
        FeaturedSection(title: "Featured", items: previewItems)
    }
}
