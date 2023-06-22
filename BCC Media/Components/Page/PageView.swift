//
//  View.swift
//  appletv
//
//  Created by Fredrik Vedvik on 14/03/2023.
//

import SwiftUI

struct PageDetailsSection: View {
    var title: String?
    var description: String?

    init(_ title: String?, _ description: String?) {
        self.title = title
        self.description = description
    }

    var body: some View {
        VStack(alignment: .leading) {
            if let t = title {
                Text(t).font(.barlowTitle)
            }
            if let d = description {
                Text(d).font(.barlowCaption).foregroundColor(.gray)
            }
        }
        .focusable()
    }
}

struct PageView: View {
    var page: API.GetPageQuery.Data.Page

    var clickItem: ClickItem

    init(_ page: API.GetPageQuery.Data.Page, clickItem: @escaping ClickItem) {
        self.page = page
        self.clickItem = clickItem
    }

    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 50) {
                ForEach(page.sections.items.indices, id: \.self) { index in
                    SectionView(page, index, clickItem: clickItem)
                }
            }
            .padding(100)
        }
        .padding(-100)
        .navigationTitle(page.title)
        .onAppear {
            Events.page(page.code)
        }
    }
}
