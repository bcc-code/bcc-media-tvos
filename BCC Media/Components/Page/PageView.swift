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
        }
    }
}

struct PageDisplay: View {
    var page: API.GetPageQuery.Data.Page

    var clickItem: (Item) -> Void

    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 50) {
                ForEach(page.sections.items, id: \.id) { section in
                    if let itemSection = section.asItemSection {
                        if !itemSection.items.items.isEmpty {
                            switch section.__typename! {
                            case "PosterSection":
                                PosterSection(
                                    itemSection.title,
                                    mapToItems(itemSection.items),
                                    clickItem: clickItem
                                )
                            case "FeaturedSection":
                                FeaturedSection(
                                    itemSection.title,
                                    mapToItems(itemSection.items),
                                    clickItem: clickItem
                                )
                            case "DefaultSection":
                                DefaultSection(
                                    itemSection.title,
                                    mapToItems(itemSection.items),
                                    clickItem: clickItem
                                )
                            case "IconSection":
                                IconSection(
                                    itemSection.title,
                                    mapToItems(itemSection.items),
                                    clickItem: clickItem
                                )
                            case "CardSection":
                                CardSection(
                                    itemSection.title,
                                    mapToItems(itemSection.items),
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
                        case "AchievementsSection":
                            EmptyView()
                        default:
                            MissingContent(section.__typename ?? "unknown type")
                        }
                    }
                }
            }.padding(100)
        }.navigationTitle(page.title).padding(-100)
    }
}

struct PageView: View {
    @State var pageId: String
    @State var page: API.GetPageQuery.Data.Page? = nil

    var clickItem: (Item) -> Void

    init(pageId: String, clickItem: @escaping ((Item) -> Void)) {
        self.pageId = pageId
        self.clickItem = clickItem
    }

    func load() {
        page = nil

        apolloClient.fetch(query: API.GetPageQuery(
            id: pageId
        )) { result in
            switch result {
            case let .success(res):
                if let p = res.data {
                    page = p.page
                } else if let errs = res.errors {
                    print(errs)
                }
            case .failure:
                print("FAILED")
            }

            print("Page loaded: " + self.pageId)
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            if let p = page {
                PageDisplay(page: p, clickItem: clickItem)
                    .refreshable { load() }
                    .transition(.opacity)
            }
        }.task { load() }.frame(width: .infinity)
    }
}

extension PageView: Hashable {
    static func == (lhs: PageView, rhs: PageView) -> Bool {
        lhs.pageId == rhs.pageId
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(pageId)
    }
}

struct PageView_Previews: PreviewProvider {
    static var previews: some View {
        PageView(pageId: "-1") { item in
            print(item.title)
        }
    }
}
