//
//  Search.swift
//  appletv
//
//  Created by Fredrik Vedvik on 16/03/2023.
//

import SwiftUI
import API

struct SearchView: View {
    @Binding var queryString: String

    @State var episodeResult: [API.SearchQuery.Data.Search.Result]? = nil
    @State var showResult: [API.SearchQuery.Data.Search.Result]? = nil

    var clickItem: ClickItem
    var playCallback: PlayCallback

    var searchPage: API.GetPageQuery.Data.Page? = nil

    private func _clickItem(_ item: Item, group: String) async {
        Events.trigger(SearchresultClicked(
            searchText: queryString,
            elementPosition: item.index,
            elementType: item.type.rawValue,
            elementId: item.id,
            group: group
        ))
        await clickItem(item, nil)
    }

    func getResult(_ query: String) async {
        if query == "" {
            episodeResult = nil
            showResult = nil
            return
        }

        let start = Date.now
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                guard let data = await apolloClient.getAsync(query: API.SearchQuery(query: query, collection: "episode")) else {
                    return
                }
                episodeResult = data.search.result
            }
            group.addTask {
                guard let data = await apolloClient.getAsync(query: API.SearchQuery(query: query, collection: "show")) else {
                    return
                }
                showResult = data.search.result
            }
        }
        Events.trigger(SearchPerformed(
            searchText: query,
            searchLatency: Date.now.timeIntervalSince(start),
            searchResultCount: (episodeResult?.count ?? 0) + (showResult?.count ?? 0)
        )
        )
    }

    func mapToItem(_ type: ItemType) -> ((API.SearchQuery.Data.Search.Result) -> Item) {
        func toItem(_ r: API.SearchQuery.Data.Search.Result) -> Item {
            Item(id: r.id, title: r.title, description: r.description ?? "", image: r.image, type: type)
        }
        return toItem
    }

    func mapToItems(_ type: ItemType, _ items: [API.SearchQuery.Data.Search.Result]) -> [Item] {
        var r: [Item] = []

        items.indices.forEach { index in
            var item = mapToItem(type)(items[index])
            item.index = index
            r.append(item)
        }

        return r
    }

    var body: some View {
        VStack {
            if showResult == nil || episodeResult == nil {
                Text("search_inputField")
            } else {
                ScrollView(.vertical) {
                    LazyVStack {
                        if let i = showResult, i.count > 0 {
                            DefaultSection(NSLocalizedString("common_shows", comment: ""), mapToItems(.show, i)) { item in
                                await _clickItem(item, group: "shows")
                            }
                        }
                        if let i = episodeResult, i.count > 0 {
                            DefaultGridSection(NSLocalizedString("common_episodes", comment: ""), mapToItems(.episode, i)) { item in
                                await _clickItem(item, group: "episodes")
                            }
                        }
                    }.padding(100)
                }.padding(-100)
            }
        }
        .searchable(text: $queryString).font(.barlow)
        .onChange(of: queryString) { query in
            Task {
                await getResult(query)
            }
        }
        .onAppear {
            Events.page("search")
        }
    }
}

struct SearchView_Preview: PreviewProvider {
    @State static var query = ""

    static var previews: some View {
        SearchView(queryString: $query) { _, _ in

        } playCallback: { _, _ in
        }
    }
}
