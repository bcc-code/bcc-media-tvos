//
//  ItemSection.swift
//  appletv
//
//  Created by Fredrik Vedvik on 10/03/2023.
//

import SwiftUI

struct SectionItemView: View {
    var item: API.GetPageQuery.Data.Page.Sections.Item.AsItemSection.Items.Item

    init(item: API.GetPageQuery.Data.Page.Sections.Item.AsItemSection.Items.Item) {
        self.item = item
    }

    var body: some View {
        Button(
                action: {},
                label: {
                    VStack(spacing: 4) {
                        AsyncImage(url: URL(string: item.image!)) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                                .scaledToFill().frame(width: 320, height: 180).clipped()
                        Text(item.title).font(.body).padding(.vertical)
                    }
                }
        )
                .buttonStyle(.card)
    }
}

struct ItemSectionView: View {
    var section: API.GetPageQuery.Data.Page.Sections.Item.AsItemSection

    init(section: API.GetPageQuery.Data.Page.Sections.Item.AsItemSection) {
        self.section = section
    }

    var body: some View {
        VStack {
            if let title = section.title {
                Text(title).font(.title3).frame(maxWidth: .infinity, alignment: .leading)
            }
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(section.items.items, id: \.id) { item in
                        SectionItemView(item: item)
                    }
                }
                        .padding(2).clipped()
            }
        }
    }
}
