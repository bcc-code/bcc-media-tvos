//
// Created by Fredrik Vedvik on 21/03/2023.
//

import SwiftUI

struct FeaturedButton: ButtonStyle {
    let focused: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.zero)
            .scaleEffect(configuration.isPressed || focused ? 1.05 : 1)
            .animation(.easeOut(duration: 0.2), value: (configuration.isPressed || focused))
    }
}

struct FeaturedCard: View {
    var item: Item

    @FocusState var isFocused: Bool

    var body: some View {
        NavigationLink {
            EpisodeViewer(episodeId: item.id)
        } label: {
            ItemImage(image: item.image)
                    .mask(LinearGradient(gradient: Gradient(colors: [.black, .black, .black, .clear]), startPoint: .top, endPoint: .bottom))
                    .cornerRadius(10)
                    .padding(.zero)
                    .overlay(
                        VStack(alignment: .leading) {
                            Text(item.title).font(.title3)
                            if item.description != "" {
                                Text(item.description).font(.subheadline)
                            }
                        }.padding(20)

                            , alignment: .bottomLeading)
        }
                .buttonStyle(FeaturedButton(focused: isFocused))
                .padding(0)
                .focused($isFocused)
    }
}

struct FeaturedSection: View {
    var title: String?
    var items: [Item]

    @State private var index = 0

    var body: some View {
        HStack {
            TabView(selection: $index) {
                ForEach(items, id: \.id) { item in
                    FeaturedCard(item: item).padding(100)
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
        FeaturedSection(title: "Featured", items: previewItems)
    }
}
