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

    init(_ page: API.GetPageQuery.Data.Page, _ index: Int, clickItem: @escaping ClickItem) {
        self.page = page
        self.index = index

        section = page.sections.items[index]
        _clickItem = clickItem
    }

    private var metadata: API.ItemSectionFragment.Metadata? {
        section.asItemSection?.metadata
    }

    /// Computed rather than mapped in `init`.
    ///
    /// SwiftUI re-creates view values on every parent body evaluation, so mapping here meant every
    /// section on the page re-built its whole `[Item]` array each time — inside a `LazyVStack` whose
    /// entire purpose is to avoid work for rows nobody is looking at. As a computed property the cost
    /// is paid only by sections that actually render, and `body` binds it once with `if let`.
    private var items: [Item]? {
        section.asItemSection.map { mapToItems($0.items, sectionIndex: index) }
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
                    // `__typename!` before — reaching here implies it is set, but the unwrap was load
                    // bearing on that inference rather than on anything enforced.
                    switch section.__typename ?? "" {
                    case "PosterSection":
                        ItemRow(
                            section.title,
                            items,
                            shape: .poster,
                            clickItem: clickItem
                        )
                    case "PosterGridSection":
                        ItemGrid(
                            section.title,
                            items,
                            shape: .poster,
                            clickItem: clickItem
                        )
                    case "FeaturedSection":
                        FeaturedSection(
                            section.title,
                            items,
                            clickItem: clickItem
                        )
                    case "DefaultSection", "ListSection":
                        ItemRow(
                            section.title,
                            items,
                            shape: .landscape,
                            clickItem: clickItem
                        )
                    case "DefaultGridSection":
                        ItemGrid(
                            section.title,
                            items,
                            shape: .landscape,
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
                    // Both render identically; they were two arms calling the same view.
                    case "CardSection", "CardListSection":
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
            }
        }
    }
}
