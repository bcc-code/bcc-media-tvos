//
//  Search.swift
//  appletv
//
//  Created by Fredrik Vedvik on 16/03/2023.
//

import SwiftUI

struct SearchView: View {
    @State var queryString = ""

    @State var episodeResult: [API.SearchQuery.Data.Search.Result]? = nil

    @State var showResult: [API.SearchQuery.Data.Search.Result]? = nil

    func getResult(query: String) {
        if query == "" {
            episodeResult = []
            showResult = []
            return
        }
        apolloClient.fetch(query: API.SearchQuery(query: query, collection: "episode")) { result in
            switch result {
            case .success(let data):
                if let r = data.data?.search.result {
                    self.episodeResult = r
                }
            case .failure(let error):
                print(error)
            }
        }
        apolloClient.fetch(query: API.SearchQuery(query: query, collection: "show")) { result in
            switch result {
            case .success(let data):
                if let r = data.data?.search.result {
                    self.showResult = r
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    func mapToItem(r: API.SearchQuery.Data.Search.Result) -> Item {
        Item(id: r.id, title: r.title, description: r.description ?? "", image: r.image)
    }

    var body: some View {
        VStack {
            if let i = showResult {
                ItemListView(
                        title: NSLocalizedString("Shows", comment: ""),
                        items: i.map(mapToItem),
                        emptyListText: Text("No shows with the current filter")
                ) { item in
                    ItemView(item: item, destination: EpisodeViewer(episodeId: item.id))
                }
            }
            if let i = episodeResult {
                ItemListView(
                        title: NSLocalizedString("Episodes", comment: ""),
                        items: i.map(mapToItem),
                        emptyListText: Text("No episodes with the current filter")
                ) { item in
                    ItemView(item: item, destination: EpisodeViewer(episodeId: item.id))
                }
            }
            if showResult == nil || episodeResult == nil {
                Text("Enter something in the search field to begin searching")
            }
        }
                .searchable(text: $queryString)
                .onChange(of: queryString, perform: getResult)
    }
}

struct SearchView_Preview: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}