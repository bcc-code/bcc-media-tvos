//
//  IconSection.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 17/04/2023.
//

import SwiftUI

struct IconSectionItem: View {
    var item: Item
    var onClick: () async -> Void

    init(_ item: Item, onClick: @escaping () async -> Void) {
        self.item = item
        self.onClick = onClick
    }

    @State private var loading = false
    @FocusState var isFocused: Bool

    var body: some View {
        VStack(spacing: 10) {
            Button {
                Task {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        loading.toggle()
                    }
                    await onClick()
                    withAnimation(.easeInOut(duration: 0.1)) {
                        loading.toggle()
                    }
                }
            } label: {
                ItemImage(item.image)
                    .frame(width: 180, height: 180)
                    .cornerRadius(10)
                    .padding(20)
                    .background(cardBackgroundColor)
                    .overlay(
                        LockView(locked: item.locked)
                    )
                    .overlay(
                        LoadingOverlay(loading)
                    )
            }
            .buttonStyle(SectionItemButton(focused: isFocused))
            .focused($isFocused)
            .accessibilityLabel(item.title)
            .accessibilityHint(item.title)
            VStack {
                Text(item.title)
            }
        }.frame(width: 200)
    }
}

struct IconSection: View {
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
                SectionTitle(t)
            }
            ScrollView(.horizontal) {
                LazyHStack(alignment: .top, spacing: 40) {
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
