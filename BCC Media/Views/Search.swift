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

    var clickItem: (Item) -> Void
    var playCallback: (EpisodePlayer) -> Void

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
            VStack {
                if let i = showResult {
                    DefaultSection(NSLocalizedString("common_shows", comment: ""), i.map(mapToItem(.show))) { item in
                        clickItem(item)
                    }
                }
                if let i = episodeResult {
                    DefaultGridSection(NSLocalizedString("common_episodes", comment: ""), i.map(mapToItem(.episode))) { item in
                        clickItem(item)
                    }
                }
                if showResult == nil || episodeResult == nil {
                    Text("search_inputField")
                }
            }.padding(100)
        }.padding(-100)
            .searchable(text: $queryString)
            .onChange(of: queryString, perform: getResult)
    }
}

struct SearchView_Preview: PreviewProvider {
    static var previews: some View {
        SearchView { _ in

        } playCallback: { _ in
        }
    }
}
