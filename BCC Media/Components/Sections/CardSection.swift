//
//  CardSection.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 17/04/2023.
//

import SwiftUI

private struct CardSectionItem: View {
    var item: Item
    var onClick: () async -> Void

    init(_ item: Item, onClick: @escaping () async -> Void) {
        self.item = item
        self.onClick = onClick
    }

    @State private var loading = false
    @FocusState var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Button {
                Task {
                    loading.toggle()
                    await onClick()
                    loading.toggle()
                }
            } label: {
                VStack(alignment: .leading) {
                    ItemImage(item.image)
                        .frame(width: 400, height: 225).cornerRadius(10)
                    VStack(alignment: .leading) {
                        Text(item.title)
                        Text(item.description).font(.caption2).foregroundColor(.gray)
                    }.padding(.horizontal, 20).padding(.bottom, 10)
                    Spacer()
                }.background(cardBackgroundColor).frame(width: 400).cornerRadius(10)
                    .overlay(
                        LockView(locked: item.locked)
                    )
                    .overlay(
                        ProgressBar(item: item),
                        alignment: .bottom
                    )
                    .overlay(
                        LoadingOverlay(loading)
                    )
            }.buttonStyle(SectionItemButton(focused: isFocused)).focused($isFocused)
        }.frame(width: 400)
    }
}

struct CardSection: View {
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
                LazyHStack(alignment: .top, spacing: 40) {
                    ForEach(items) { item in
                        CardSectionItem(item) {
                            await clickItem(item)
                        }
                    }
                }.padding(100)
            }.padding(-100)
        }
    }
}
