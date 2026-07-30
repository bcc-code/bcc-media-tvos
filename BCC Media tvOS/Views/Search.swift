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

    /// How long the query has to stay unchanged before it is sent.
    ///
    /// Every keystroke used to fire two GraphQL queries immediately. Typing on a remote is slow enough
    /// that this collapses most of them without being noticeable.
    private static let debounce = Duration.milliseconds(300)

    /// Runs from `.task(id: queryString)`, which cancels the previous run whenever the query changes.
    ///
    /// `@MainActor` because it writes `@State`. The previous version assigned to `episodeResult` and
    /// `showResult` from inside `withTaskGroup` child tasks, so two child tasks wrote view state off
    /// the main actor, and the `SearchPerformed` count read those properties right after the group —
    /// racing whichever assignment happened to land.
    @MainActor
    private func search(for query: String) async {
        guard !query.isEmpty else {
            // A cleared field starts a new search session.
            AppOptions.searchSessionId = UUID().uuidString
            episodeResult = nil
            showResult = nil
            return
        }

        do {
            try await Task.sleep(for: Self.debounce)
        } catch {
            // Cancelled during the debounce: a newer query arrived, so this one is not worth sending.
            return
        }

        let start = Date.now
        // `async let` rather than a task group: two fixed requests whose values come back to the caller,
        // instead of two child tasks writing into shared state.
        async let episodeRequest = apolloClient.getAsync(query: API.SearchQuery(query: query, collection: "episode"))
        async let showRequest = apolloClient.getAsync(query: API.SearchQuery(query: query, collection: "show"))
        let (episodeData, showData) = await (episodeRequest, showRequest)

        // A slow response for an older query could otherwise overwrite a newer one's results.
        guard !Task.isCancelled else {
            return
        }

        let episodes = episodeData?.search.result
        let shows = showData?.search.result
        episodeResult = episodes
        showResult = shows

        Events.trigger(SearchPerformed(
            searchText: query,
            searchLatency: Date.now.timeIntervalSince(start),
            searchResultCount: (episodes?.count ?? 0) + (shows?.count ?? 0)
        ))
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
        // Keyed on the query, so SwiftUI cancels the in-flight search when it changes. The previous
        // `onChange` spawned an unstructured Task per keystroke with nothing cancelling the last one.
        .task(id: queryString) {
            await search(for: queryString)
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
