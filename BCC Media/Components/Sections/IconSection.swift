//
//  PosterSection.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 17/04/2023.
//

import SwiftUI

struct IconSection: View {
    var title: String?
    var items: [Item]
    var clickItem: (Item) -> Void

    init(_ title: String?, _ items: [Item], clickItem: @escaping (Item) -> Void) {
        self.title = title
        self.items = items
        self.clickItem = clickItem
    }

    var body: some View {
        VStack {
            if let t = title {
                Text(t).font(.title3).frame(maxWidth: .infinity, alignment: .leading)
            }
            ScrollView(.horizontal) {
                LazyHStack(alignment: .top, spacing: 60) {
                    ForEach(items) { item in
                        VStack(spacing: 10) {
                            Button {
                                clickItem(item)
                            } label: {
                                ItemImage(item.image)
                                    .frame(width: 180, height: 180)
                                    .cornerRadius(10)
                                    .padding(20)
                                    .background(cardBackgroundColor)
                            }.buttonStyle(.card)
                            VStack {
                                Text(item.title)
                            }
                        }.frame(width: 200)
                    }
                }.padding(100)
            }.padding(-100)
        }
    }
}
