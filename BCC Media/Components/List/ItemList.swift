//
// Created by Fredrik Vedvik on 16/03/2023.
//

import SwiftUI

struct Item {
    var id: String
    var title: String
    var image: String?
}

struct ItemImage: View {
    var image: String?

    var body: some View {
        AsyncImage(url: image != nil ? URL(string: image! + "?w=400&h=225") : nil) { image in
            image.resizable().renderingMode(.original)
        } placeholder: {
            ProgressView()
        }
    }
}

struct ItemListView<Destination: View>: View {
    var title: String?
    var items: [Item]
    var emptyListText: Text?

    var destinationFactory: (Item) -> Destination

    var body: some View {
        VStack {
            if let t = title {
                Text(t).font(.title3).frame(maxWidth: .infinity, alignment: .leading)
            }
            ScrollView(.horizontal) {
                LazyHStack(spacing: 20) {
                    if items.count > 0 {
                        ForEach(items.indices, id: \.self) { index in
                            let i = items[index]
                            ItemView(item: i, destination: destinationFactory(i))
                        }
                    } else if let s = emptyListText {
                        s
                    }
                }
                        .lineLimit(2).padding(50)
            }
                    .padding(-50)
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
