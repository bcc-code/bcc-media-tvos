//
//  DefaultGridSection.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 17/04/2023.
//

import SwiftUI

struct DefaultGridSection: View {
    var title: String?
    var items: [Item]
    var clickItem: SectionClickItem

    init(_ title: String?, _ items: [Item], clickItem: @escaping SectionClickItem) {
        self.title = title
        self.items = items
        self.clickItem = clickItem
    }

    var columns = [GridItem(.flexible(), alignment: .top), GridItem(.flexible(), alignment: .top), GridItem(.flexible(), alignment: .top), GridItem(.flexible(), alignment: .top)]

    var body: some View {
        VStack {
            if let t = title {
                SectionTitle(t)
            }
            ScrollView(.vertical) {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(items) { item in
                        SectionItemCard(item, width: 400, height: 225) {
                            await clickItem(item)
                        }
                    }
                }.padding(100)
            }.padding(-100)
        }
    }
}

struct DefaultGridSection_Previews: PreviewProvider {
    static var previews: some View {
        DefaultGridSection("", previewItems) { item in
            print(item.title)
        }
    }
}
