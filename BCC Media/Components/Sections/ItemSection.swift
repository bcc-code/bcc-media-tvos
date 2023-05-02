//
//  ItemSection.swift
//
//  Created by Fredrik Vedvik on 10/03/2023.
//

import SwiftUI

let previewItems: [Item] = [
    Item(id: "10", title: "Another Item", description: "description", image: "https://brunstadtv.imgix.net/92a64b64-1f82-42c2-85f2-8a7ff39b1f90.jpg"),
    Item(id: "16", title: "Another Item", description: "description", image: "https://brunstadtv.imgix.net/92a64b64-1f82-42c2-85f2-8a7ff39b1f90.jpg"),
    Item(id: "12", title: "Another Item", description: "description", image: "https://brunstadtv.imgix.net/92a64b64-1f82-42c2-85f2-8a7ff39b1f90.jpg"),
    Item(id: "1", title: "Another Item", description: "description", image: "https://brunstadtv.imgix.net/92a64b64-1f82-42c2-85f2-8a7ff39b1f90.jpg"),
    Item(id: "20", title: "Another Item", description: "description", image: "https://brunstadtv.imgix.net/92a64b64-1f82-42c2-85f2-8a7ff39b1f90.jpg"),
    Item(id: "11", title: "Another Item", description: "description", image: "https://brunstadtv.imgix.net/92a64b64-1f82-42c2-85f2-8a7ff39b1f90.jpg"),
]

enum ItemType {
    case episode
    case show
    case page
    case topic
    case season
}

struct Item: Identifiable {
    var id: String
    var title: String
    var description: String
    var image: String?

    var type: ItemType = .episode
}

struct ItemTitle: View {
    var item: Item

    init(_ item: Item) {
        self.item = item
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(item.title).font(.caption2)
        }
    }
}

func mapToItem(_ item: API.ItemSectionFragment.Items.Item) -> Item {
    var t: ItemType
    switch item.item.__typename {
    case "Show":
        t = .show
    case "Episode":
        t = .episode
    case "Page":
        t = .page
    case "Season":
        t = .season
    case "StudyTopic":
        t = .topic
    default:
        t = .episode
    }
    return Item(id: item.id, title: item.title, description: item.description, image: item.image, type: t)
}

func mapToItems(_ items: API.ItemSectionFragment.Items) -> [Item] {
    items.items.map { item in
        mapToItem(item)
    }
}
