//
//  DefaultSection.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 17/04/2023.
//

import SwiftUI

struct DefaultSection: View {
    var title: String?
    var items: [Item]
    var clickItem: (Item) -> Void

    init(_ title: String?, _ items: [Item], clickItem: @escaping (Item) -> Void) {
        self.title = title
        self.items = items
        self.clickItem = clickItem
    }

    @FocusState var isFocused: Bool

    var body: some View {
        VStack {
            if let t = title {
                Text(t).font(.title3).frame(maxWidth: .infinity, alignment: .leading)
            }
            ScrollView(.horizontal) {
                LazyHStack(alignment: .top, spacing: 20) {
                    ForEach(items) { item in
                        SectionItemCard(item, width: 400, height: 225) {
                            clickItem(item)
                        }
                    }
                }.padding(100)
            }.padding(-100)
        }
    }
}

struct previews: PreviewProvider {
    static var previews: some View {
        DefaultSection("", previewItems) { item in
            print(item.title)
        }
    }
}
