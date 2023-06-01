//
//  View.swift
//  appletv
//
//  Created by Fredrik Vedvik on 14/03/2023.
//

import SwiftUI

struct MissingContent: View {
    var annotation: String

    init(_ annotation: String) {
        self.annotation = annotation
    }

    var body: some View {
        Button {
            print("oopsi")
        } label: {
            Text("Oops. Seems there is some missing content here. Work in progress.")
            Text(annotation).foregroundColor(.gray)
        }.buttonStyle(.plain)
    }
}

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
                Text(t).font(.title3)
            }
            if let d = description {
                Text(d).font(.caption).foregroundColor(.gray)
            }
        }.focusable()
    }
}

struct SectionView: View {
    var page: API.GetPageQuery.Data.Page
    var index: Int
    var section: API.GetPageQuery.Data.Page.Sections.Item

    private var _clickItem: ClickItem

    var metadata: API.ItemSectionFragment.Metadata?
    var items: [Item]?

    init(_ page: API.GetPageQuery.Data.Page, _ index: Int, clickItem: @escaping ClickItem) {
        self.page = page
        self.index = index

        section = page.sections.items[index]
        _clickItem = clickItem

        if let itemSection = section.asItemSection {
            metadata = itemSection.metadata
            items = mapToItems(itemSection.items)
        }
    }

    func clickItem(item: Item) async {
        await _clickItem(item)

        Events.trigger(SectionClicked(
            sectionId: section.id,
            sectionName: section.title ?? "",
            sectionPosition: index,
            sectionType: section.__typename ?? "",
            elementPosition: item.index,
            elementType: item.type.rawValue,
            elementId: item.id,
            elementName: item.title,
            pageCode: page.code
        ))
    }

    var body: some View {
        if let items = items {
            if !items.isEmpty {
                switch section.__typename! {
                case "PosterSection":
                    PosterSection(
                        section.title,
                        items,
                        clickItem: clickItem
                    )
                case "FeaturedSection":
                    FeaturedSection(
                        section.title,
                        items,
                        clickItem: clickItem,
                        withLiveElement: metadata?.prependLiveElement == true
                    )
                case "DefaultSection":
                    DefaultSection(
                        section.title,
                        items,
                        clickItem: clickItem
                    )
                case "DefaultGridSection":
                    DefaultGridSection(
                        section.title,
                        items,
                        clickItem: clickItem
                    )
                case "IconSection":
                    IconSection(
                        section.title,
                        items,
                        clickItem: clickItem
                    )
                case "CardSection":
                    CardSection(
                        section.title,
                        items,
                        clickItem: clickItem
                    )
                case "LabelSection":
                    LabelSection(
                        section.title,
                        items,
                        clickItem: clickItem
                    )
                default:
                    MissingContent(section.__typename ?? "unknown type")
                }
            }
        } else {
            switch section.__typename {
            case "MessageSection":
                EmptyView()
            case "PageDetailsSection":
                PageDetailsSection(section.title, section.description)
            case "AchievementSection":
                EmptyView()
            default:
                MissingContent(section.__typename ?? "unknown type")
            }
        }
    }
}

struct PageView: View {
    var page: API.GetPageQuery.Data.Page

    var clickItem: ClickItem

    init(_ page: API.GetPageQuery.Data.Page, clickItem: @escaping ClickItem) {
        self.page = page
        self.clickItem = clickItem

        Events.page(page.code)
    }

    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 50) {
                ForEach(page.sections.items.indices, id: \.self) { index in
                    SectionView(page, index, clickItem: clickItem)
                }
            }.padding(100)
        }.padding(-100)
            .navigationTitle(page.title)
    }
}
