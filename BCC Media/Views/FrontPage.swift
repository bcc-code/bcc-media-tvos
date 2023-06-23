//
//  FrontPage.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 13/06/2023.
//

import SwiftUI

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
        }.task {
            if let pageId = pageId {
                page = await getPage(pageId)
            }
        }
    }
}
