//
//  FrontPage.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 13/06/2023.
//

import SwiftUI

// This is a struct to distinguish the first page component from any subpages.
struct FrontPage: View {
    var page: API.GetPageQuery.Data.Page?
    var clickItem: ClickItem

    init(page: API.GetPageQuery.Data.Page?, clickItem: @escaping ClickItem) {
        self.page = page
        self.clickItem = clickItem
    }

    var body: some View {
        ZStack {
            if let page = page {
                PageView(page, clickItem: clickItem)
            }
        }
    }
}
