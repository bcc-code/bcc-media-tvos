//
//  ContentProvider.swift
//  BCC Media Top Shelf
//
//  Created by Fredrik Vedvik on 21/03/2023.
//

import TVServices

class ContentProvider: TVTopShelfContentProvider {
    override func loadTopShelfContent(completionHandler: @escaping (TVTopShelfContent?) -> Void) {
        // Fetch content and call completionHandler
        
        Task {
            var items: [TVTopShelfSectionedItem] = []
            
            let i = TVTopShelfSectionedItem(identifier: "ok")
            i.title = "Title"
            i.setImageURL(URL(string: "https://images.all-free-download.com/images/graphiclarge/hd_flower_picture_01_hd_pictures_167032.jpg")!, for: TVTopShelfItem.ImageTraits())
            
            items.append(i)
            
            let section = TVTopShelfItemCollection<TVTopShelfSectionedItem>(items: items)
            let sections: [TVTopShelfItemCollection<TVTopShelfSectionedItem>] = [section]
            
            
            let content = TVTopShelfSectionedContent(sections: sections)
            
            completionHandler(content);
        }
    }
}
