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
                return
            }
            // Keep the last good page on a failed refresh rather than blanking the screen.
            if let fetched = await getPage(pageId) {
                page = fetched
            }
        }
    }
}
