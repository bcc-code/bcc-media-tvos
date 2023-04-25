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
        Button{
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

    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 50) {
                ForEach(page.sections.items, id: \.id) {section in
                    if let itemSection = section.asItemSection {
                        if !itemSection.items.items.isEmpty {
                            switch itemSection.__typename {
                            case "PosterSection":
                                PosterSection(title: itemSection.title, items: itemSection.items.items.map(mapToItem))
                            case "FeaturedSection":
                                FeaturedSection(title: itemSection.title, items: itemSection.items.items.map(mapToItem))
                            case "DefaultSection":
                                DefaultSection(title: itemSection.title, items: itemSection.items.items.map(mapToItem))
                            case "IconSection":
                                IconSection(title: itemSection.title, items: mapToItems(itemSection.items))
                            case "CardSection":
                                CardSection(itemSection.title, mapToItems(itemSection.items))
                            default:
                                MissingContent(section.__typename)
                            }
                        }
                    } else {
                        switch section.__typename {
                        case "MessageSection":
                            EmptyView()
                        case "PageDetailsSection":
                            PageDetailsSection(section.title, section.description)
                        default:
                            MissingContent(section.__typename)
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
    
    init(pageId: String) {
        self.pageId = pageId
    }

    func load() {
        page = nil
        apolloClient.fetch(query: API.GetPageQuery(id: pageId)) { result in
            switch result {
            case let .success(res):
                if let p = res.data {
                    page = p.page
                }
            case .failure:
                print("FAILED")
            }

            print("OK")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if let p = page {
                PageDisplay(page: p).refreshable { load() }
            } else {
                ProgressView()
            }
        }.task { load() }.frame(width: .infinity)
    }
}

struct PageView_Previews: PreviewProvider {
    static var previews: some View {
        PageView(pageId: "-1")
    }
}
