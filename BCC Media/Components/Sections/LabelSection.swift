//
//  LabelSection.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 17/04/2023.
//

import SwiftUI

struct LabelSection: View {
    var title: String?
    var items: [Item]
    var clickItem: SectionClickItem

    init(_ title: String?, _ items: [Item], clickItem: @escaping SectionClickItem) {
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
                LazyHStack(alignment: .top, spacing: 20) {
                    ForEach(items) { item in
                        Button {
                            Task {
                                await clickItem(item)
                            }
                        } label: {
                            Text(item.title)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(cardBackgroundColor)
                                .cornerRadius(10).overlay(
                                    LockView(locked: item.locked)
                                )
                        }.buttonStyle(.card)
                    }
                }.padding(100)
            }.padding(-100)
        }
    }
}

struct LabelSection_Previews: PreviewProvider {
    static var previews: some View {
        LabelSection("", previewItems) { item in
            print(item.title)
        }
    }
}
