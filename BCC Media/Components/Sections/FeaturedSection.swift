//
// Created by Fredrik Vedvik on 21/03/2023.
//

import SwiftUI

struct FeaturedButton: ButtonStyle {
    let focused: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.zero)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(.white, lineWidth: configuration.isPressed || focused ? 4 : 0))
            .scaleEffect(configuration.isPressed ? 1.05 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed || focused)
    }
}

struct FeaturedCard: View {
    var item: Item
    var clicked: () -> Void

    @FocusState var isFocused: Bool

    var body: some View {
        Button(action: clicked) {
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
                ).overlay(
                    LockView(locked: item.locked)
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
    var clickItem: (Item) -> Void

    init(_ title: String?, _ items: [Item], clickItem: @escaping (Item) -> Void) {
        self.title = title
        self.items = items
        self.clickItem = clickItem
    }

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 5) {
                ForEach(items.indices, id: \.self) { index in
                    FeaturedCard(item: items[index]) {
                        clickItem(items[index])
                    }
                }.frame(width: 1800)
            }.padding(100)
        }.padding(-100)
        .frame(width: 1800, height: 800)
    }
}

struct FeaturedSection_Previews: PreviewProvider {
    static var previews: some View {
        FeaturedSection(nil, previewItems) { item in
            
        }
    }
}
