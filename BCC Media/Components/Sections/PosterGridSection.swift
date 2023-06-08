//
//  PosterGridSection.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 17/04/2023.
//

import SwiftUI

struct PosterGridSection: View {
    var title: String?
    var items: [Item]
    var clickItem: SectionClickItem

    init(_ title: String?, _ items: [Item], clickItem: @escaping SectionClickItem) {
        self.title = title
        self.items = items
        self.clickItem = clickItem
    }

    var columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack {
            if let t = title {
                Text(t).font(.title3).frame(maxWidth: .infinity, alignment: .leading)
            }
            ScrollView(.vertical) {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(items) { item in
                        SectionItemCard(item, width: 400, height: 600) {
                            await clickItem(item)
                        }
                    }
                }.padding(100)
            }.padding(-100)
        }
    }
}

struct PosterGridSection_Previews: PreviewProvider {
    static var previews: some View {
        PosterGridSection("test", previewItems) { i in
            print(i)
        }
    }
}
