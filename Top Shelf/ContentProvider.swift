//
//  ContentProvider.swift
//  Top Shelf
//
//  Created by Fredrik Vedvik on 25/04/2023.
//

import TVServices

class ContentProvider: TVTopShelfContentProvider {

    override func loadTopShelfContent(completionHandler: @escaping (TVTopShelfContent?) -> Void) {
        // Fetch content and call completionHandler
        
        let item = TVTopShelfItem(identifier: "one")
        
        item.title = "One"
        item.setImageURL(URL(string: "https://brunstadtv.imgix.net/92a64b64-1f82-42c2-85f2-8a7ff39b1f90.jpg"), for: .screenScale2x)
        
        completionHandler(TVTopShelfInsetContent(items: [item]));
    }

}

