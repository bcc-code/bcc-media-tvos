//
// Created by Fredrik Vedvik on 16/03/2023.
//

import SwiftUI

struct Item: Identifiable {
    var id: String
    var title: String
    var description: String
    var image: String?
}

struct ItemImage: View {
    var image: String?

    var body: some View {
        GeometryReader { proxy in
            if proxy.size != .zero, let img = image {
                VStack {
                    AsyncImage(url: URL(string: img + "?w=\(Int(proxy.size.width))&h=\(Int(proxy.size.height))&crop=faces&fit=crop")) { image in
                        image.resizable().renderingMode(.original)
                    } placeholder: {
                        ProgressView()
                    }
                }
                        .frame(width: proxy.size.width, height: proxy.size.height)
            }
        }
    }
}

struct ItemListView<IView: View>: View {
    var title: String?
    var items: [Item]
    var emptyListText: Text?

    var view: (Item) -> IView

    var body: some View {
        VStack {
            if let t = title {
                Text(t).font(.title3).frame(maxWidth: .infinity, alignment: .leading)
            }
            ScrollView(.horizontal) {
                LazyHStack(spacing: 20) {
                    if items.count > 0 {
                        ForEach(items.indices, id: \.self) { index in
                            view(items[index])
                        }
                    } else if let s = emptyListText {
                        s
                    }
                }
                        .lineLimit(2).padding(100)
            }
                    .padding(-100)
        }
    }
}

struct ItemView<Destination: View>: View {
    var item: Item
    var destination: Destination

    init(item: Item, destination: Destination) {
        self.item = item
        self.destination = destination
    }

    var body: some View {
        VStack {
            NavigationLink {
                destination
            } label: {
                ItemImage(image: item.image).frame(width: 400, height: 225)
            }
                    .buttonStyle(.card)
                    .padding(.zero)
            Text(item.title).padding(.zero).font(.caption)
        }
                .frame(width: 400)
    }
}
