//
//  Search.swift
//  appletv
//
//  Created by Fredrik Vedvik on 16/03/2023.
//

import SwiftUI

struct SearchView: View {
    @State var queryString = ""

    @State var result: [API.SearchQuery.Data.Search.Result]? = nil

    func getResult(query: String) {
        Task {
            apolloClient.fetch(query: API.SearchQuery(query: query, collection: "episode")) { result in
                switch result {
                case .success(let data):
                    if let r = data.data?.search.result {
                        self.result = r
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack {
                if let r = result {
                    ForEach(r, id: \.id) { row in
                        NavigationLink {
                            EpisodeViewer(episodeId: row.id)
                        }
                        label: {
                            VStack(spacing: 4) {
                                AsyncImage(url: URL(string: row.image!)) { image in
                                    image.resizable()
                                } placeholder: {
                                    ProgressView()
                                }
                                        .scaledToFill().frame(width: 320, height: 180).clipped()
                                Text(row.title).font(.caption).lineLimit(2)
                            }
                                    .frame(width: 320)
                        }
                                .buttonStyle(PlainButtonStyle()).frame(width: 320)
                    }
                } else {
                    Text("No results")
                }
            }
        }
                .searchable(text: $queryString).onChange(of: queryString) { query in
                    getResult(query: query)
                }
                .padding(.zero)

    }
}

struct SearchView_Preview: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}