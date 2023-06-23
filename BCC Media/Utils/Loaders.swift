//
//  Loaders.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 23/06/2023.
//

func getPage(_ id: String) async -> API.GetPageQuery.Data.Page {
    let data = await apolloClient.getAsync(query: API.GetPageQuery(id: id))
    return data!.page
}
