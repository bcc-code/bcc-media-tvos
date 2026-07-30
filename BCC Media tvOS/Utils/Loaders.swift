//
//  Loaders.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 23/06/2023.
//
import API

/// Returns nil when the query fails, rather than trapping. The front page is the first thing loaded
/// on launch, so `data!.page` here turned any network hiccup into a crash on the most-travelled path.
func getPage(_ id: String) async -> API.GetPageQuery.Data.Page? {
    await apolloClient.getAsync(query: API.GetPageQuery(id: id))?.page
}
