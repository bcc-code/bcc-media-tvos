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

    /// Named distinctly from `mapToItems(_:sectionIndex:)` in `ItemSection.swift` — both were global to
    /// the target under the same name, differing only in argument type.
    func mapSearchResults(_ type: ItemType, _ results: [API.SearchQuery.Data.Search.Result]) -> [Item] {
        results.enumerated().map { index, result in
            Item(
                id: result.id,
                title: result.title,
                showTitle: result.asEpisodeSearchItem?.showTitle,
                seasonTitle: result.asEpisodeSearchItem?.seasonTitle,
                description: result.description ?? "",
                image: result.image,
                type: type,
                index: index
            )
        }
    }

    var body: some View {
        VStack {
            if showResult == nil || episodeResult == nil {
                Text("search_inputField")
            } else {
                ScrollView(.vertical) {
                    LazyVStack {
                        if let i = showResult, i.count > 0 {
                            ItemRow(String(localized: "common_shows"), mapSearchResults(.show, i), shape: .landscape) { item in
                                await _clickItem(item, group: "shows")
                            }
                        }
                        if let i = episodeResult, i.count > 0 {
                            ItemGrid(String(localized: "common_episodes"), mapSearchResults(.episode, i), shape: .landscape) { item in
                                await _clickItem(item, group: "episodes")
                            }
                        }
                    }.padding(100)
                }.padding(-100)
            }
        }
        .searchable(text: $queryString).font(.barlow)
        .onChange(of: queryString) { query in
            if query.isEmpty {
                AppOptions.searchSessionId = UUID().uuidString
            }
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
        }
    }
}
