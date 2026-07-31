//
//  FrontPage.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 13/06/2023.
//

import SwiftUI
import API

// This is a struct to distinguish the first page component from any subpages.
struct FrontPage: View {
    var pageId: String?
    var clickItem: ClickItem
    
    @State var page: API.GetPageQuery.Data.Page?

    /// Which `pageId` the page currently on screen was fetched for.
    ///
    /// Tracked rather than read back off `page.id`, so this cannot be fooled if the API ever answers
    /// a request for one id with a page carrying another.
    @State private var loadedPageId: String?

    init(pageId: String?, clickItem: @escaping ClickItem) {
        self.pageId = pageId
        self.clickItem = clickItem
    }

    var body: some View {
        ZStack {
            if let page = page {
                PageView(page, clickItem: clickItem)
            }
        }
        // Keyed on `pageId`, so the page is re-fetched when it changes — plain `.task` runs once per
        // view identity, which meant signing in kept showing the anonymous front page even though
        // `GetSetupQuery` had returned a different id.
        .task(id: pageId) {
            guard let pageId = pageId else {
                page = nil
                loadedPageId = nil
                return
            }
            // A *different* page has to go before the fetch, not after it. Signing out changes the id,
            // and on a shared TV the previous user's personalised page would otherwise stay on screen
            // — visible and clickable — for as long as the new fetch takes, and permanently if it
            // fails.
            if loadedPageId != pageId {
                page = nil
                loadedPageId = nil
            }
            // The same page is left up while it re-fetches, so returning to this tab does not blank it
            // and a failed refresh keeps the last good page rather than nothing.
            if let fetched = await getPage(pageId) {
                // `getAsync` does not observe cancellation, so a slow response for the id this task
                // replaced still arrives and would put the old page back. Same race `Search` guards.
                guard !Task.isCancelled else {
                    return
                }
                page = fetched
                loadedPageId = pageId
            }
        }
    }
}
