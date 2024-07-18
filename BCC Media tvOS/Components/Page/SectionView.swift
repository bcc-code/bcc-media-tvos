//
// Created by Fredrik Vedvik on 21/06/2023.
//

import API
import SwiftUI

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
            items = mapToItems(itemSection.items, sectionIndex: index)
        }
    }

    func clickItem(item: Item) async {
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

        if metadata?.useContext == true, let collectionId = metadata?.collectionId {
            await _clickItem(item, API.EpisodeContext(collectionId: .init(stringLiteral: collectionId)))
        } else {
            await _clickItem(item, nil)
        }
    }

    var body: some View {
        if let items = items {
            if items.isEmpty {
                EmptyView()
            } else {
                VStack {
                    switch section.__typename! {
                    case "PosterSection":
                        PosterSection(
                            section.title,
                            items,
                            clickItem: clickItem
                        )
                    case "PosterGridSection":
                        PosterGridSection(
                            section.title,
                            items,
                            clickItem: clickItem
                        )
                    case "FeaturedSection":
                        FeaturedSection(
                            section.title,
                            items,
                            clickItem: clickItem
                        )
                    case "DefaultSection", "ListSection":
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
                    case "IconGridSection":
                        IconGridSection(
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
                    case "CardListSection":
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
                        EmptyView()
                        // MissingContent(section.__typename ?? "unknown type")
                    }
                }.padding(.bottom, 50)
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
                EmptyView()
                // MissingContent(section.__typename ?? "unknown type")
            }
        }
    }
}

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
        }
        .buttonStyle(.plain)
    }
}
