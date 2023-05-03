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
            case let .success(data):
                if let r = data.data?.search.result {
                    self.episodeResult = r
                }
            case let .failure(error):
                print(error)
            }
        }
        apolloClient.fetch(query: API.SearchQuery(query: query, collection: "show")) { result in
            switch result {
            case let .success(data):
                if let r = data.data?.search.result {
                    self.showResult = r
                }
            case let .failure(error):
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
                    title: NSLocalizedString("common_shows", comment: ""),
                    items: i,
                    emptyListText: Text("search_noShowsWithCurrentFilter")
                ) { item in
                    ItemView(item.title, item.image, destination: EpisodeViewer(episodeId: item.id))
                }
            }
            if let i = episodeResult {
                ItemListView(
                    title: NSLocalizedString("common_episodes", comment: ""),
                    items: i,
                    emptyListText: Text("search_noEpisodesWithCurrentFilter")
                ) { item in
                    ItemView(item.title, item.image, destination: EpisodeViewer(episodeId: item.id))
                }
            }
            if showResult == nil || episodeResult == nil {
                Text("search_inputField")
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
