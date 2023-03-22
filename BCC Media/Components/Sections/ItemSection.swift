//
//  ItemSection.swift
//
//  Created by Fredrik Vedvik on 10/03/2023.
//

import SwiftUI

struct ItemSectionView: View {
    var __typename: String
    var title: String?
    var items: API.ItemSectionFragment.Items

    func mapToItem(item: API.ItemSectionFragment.Items.Item) -> Item {
        Item(id: item.id, title: item.title, description: item.description, image: item.image)
    }

    func getItems() -> [Item] {
        items.items.map(mapToItem)
    }

    var body: some View {
        switch __typename {
        case "FeaturedSection":
            FeaturedSection(title: title, items: getItems())
        default:
            ItemListView(title: title, items: getItems()) { item in
                ItemView(item: item, destination: EpisodeViewer(episodeId: item.id))
            }
        }
    }
}

