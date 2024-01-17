//
//  IconSection.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 17/04/2023.
//

import SwiftUI

struct IconGridSection: View {
    var title: String?
    var items: [Item]
    var clickItem: SectionClickItem

    init(_ title: String?, _ items: [Item], clickItem: @escaping SectionClickItem) {
        self.title = title
        self.items = items
        self.clickItem = clickItem
    }

    var columns = [
        GridItem(.flexible(), alignment: .top),
        GridItem(.flexible(), alignment: .top),
        GridItem(.flexible(), alignment: .top),
        GridItem(.flexible(), alignment: .top),
        GridItem(.flexible(), alignment: .top),
        GridItem(.flexible(), alignment: .top),
    ]

    var body: some View {
        VStack {
            if let t = title {
                SectionTitle(t)
            }
            ScrollView(.vertical) {
                LazyVGrid(columns: columns, spacing: 40) {
                    ForEach(items) { item in
                        IconSectionItem(item) {
                            await clickItem(item)
                        }
                    }
                }.padding(100)
            }.padding(-100)
        }
    }
}
