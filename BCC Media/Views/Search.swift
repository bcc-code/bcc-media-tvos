//
//  Search.swift
//  appletv
//
//  Created by Fredrik Vedvik on 16/03/2023.
//

import SwiftUI

struct SearchView: View {
    @Binding var queryString: String

    @State var episodeResult: [API.SearchQuery.Data.Search.Result]? = nil
    @State var showResult: [API.SearchQuery.Data.Search.Result]? = nil

    var clickItem: ClickItem
    var playCallback: (EpisodePlayer) -> Void

    func getResult(_ query: String) async {
        if query == "" {
            episodeResult = nil
            showResult = nil
            return
        }

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
    }

    func mapToItem(_ type: ItemType) -> ((API.SearchQuery.Data.Search.Result) -> Item) {
        func toItem(_ r: API.SearchQuery.Data.Search.Result) -> Item {
            Item(id: r.id, title: r.title, description: r.description ?? "", image: r.image, type: type)
        }
        return toItem
    }

    func mapToItem(r: API.SearchQuery.Data.Search.Result) -> Item {
        Item(id: r.id, title: r.title, description: r.description ?? "", image: r.image)
    }

    var body: some View {
        ScrollView(.vertical) {
            LazyVStack {
                if let i = showResult, i.count > 0 {
                    DefaultSection(NSLocalizedString("common_shows", comment: ""), i.map(mapToItem(.show))) { item in
                        await clickItem(item)
                    }
                }
                if let i = episodeResult, i.count > 0 {
                    DefaultGridSection(NSLocalizedString("common_episodes", comment: ""), i.map(mapToItem(.episode))) { item in
                        await clickItem(item)
                    }
                }
                if showResult == nil || episodeResult == nil {
                    Text("search_inputField")
                }
            }.padding(100)
        }.padding(-100)
            .searchable(text: $queryString)
            .onChange(of: queryString) { query in
                Task {
                    await getResult(query)
                }
            }
    }
}

struct SearchView_Preview: PreviewProvider {
    @State static var query = ""

    static var previews: some View {
        SearchView(queryString: $query) { _ in

        } playCallback: { _ in
        }
    }
}
