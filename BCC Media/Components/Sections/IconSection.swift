//
//  IconSection.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 17/04/2023.
//

import SwiftUI

struct IconSectionItem: View {
    var item: Item
    var onClick: () -> Void
    
    init(_ item: Item, onClick: @escaping () -> Void) {
        self.item = item
        self.onClick = onClick
    }
    
    @FocusState var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            Button {
                onClick()
            } label: {
                ItemImage(item.image)
                    .frame(width: 180, height: 180)
                    .cornerRadius(10)
                    .padding(20)
                    .background(cardBackgroundColor).overlay(
                        LockView(locked: item.locked)
                    )
            }
            .buttonStyle(SectionItemButton(focused: isFocused))
            .focused($isFocused)
            VStack {
                Text(item.title)
            }
        }.frame(width: 200)
    }
}

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
                LazyHStack(alignment: .top, spacing: 40) {
                    ForEach(items) { item in
                        IconSectionItem(item) {
                            clickItem(item)
                        }
                    }
                }.padding(100)
            }.padding(-100)
        }
    }
}
