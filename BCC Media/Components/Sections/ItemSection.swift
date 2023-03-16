//
//  ItemSection.swift
//  appletv
//
//  Created by Fredrik Vedvik on 10/03/2023.
//

import SwiftUI


//
//struct SectionItemView: View {
//    var item: API.GetPageQuery.Data.Page.Sections.Item.AsItemSection.Items.Item
//
//    init(item: API.GetPageQuery.Data.Page.Sections.Item.AsItemSection.Items.Item) {
//        self.item = item
//    }
//
//    var body: some View {
//        VStack {
//            NavigationLink {
//                EpisodeViewer(episodeId: item.id)
//            } label: {
//                ItemImage(image: item.image).frame(width: 320, height: 180)
//            }
//                    .buttonStyle(.card)
//                    .padding(.zero)
//            Text(item.title).padding(.zero).font(.caption)
//        }
//                .frame(width: 320)
//    }
//}

struct ItemSectionView: View {
    var section: API.GetPageQuery.Data.Page.Sections.Item.AsItemSection

    init(section: API.GetPageQuery.Data.Page.Sections.Item.AsItemSection) {
        self.section = section
    }

    func mapToItem(item: API.GetPageQuery.Data.Page.Sections.Item.AsItemSection.Items.Item) -> Item {
        Item(id: item.id, title: item.title, image: item.image)
    }

    var body: some View {
        ItemListView(title: section.title, items: section.items.items.map(mapToItem)) { item in
            EpisodeViewer(episodeId: item.id)
        }
    }
}

