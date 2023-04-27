//
//  ContentProvider.swift
//  Top Shelf
//
//  Created by Fredrik Vedvik on 25/04/2023.
//

import TVServices

let authenticationProvider = AuthenticationProvider(
    options: AuthenticationProviderOptions(
        client_id: "rJbKSHYPskua2BgY8mEwOSasK6o6uCRA",
        scope: "openid profile email offline_access",
        audience: "api.bcc.no",
        domain: "login.bcc.no"
    )
)

let apolloClient = ApolloClientFactory(tokenFactory: authenticationProvider.getAccessToken).NewClient()

class ContentProvider: TVTopShelfContentProvider {

    override func loadTopShelfContent(completionHandler: @escaping (TVTopShelfContent?) -> Void) {
        // Fetch content and call completionHandler
        apolloClient.fetch(query: API.GetPageQuery(id: "30")) { result in
            switch result {
            case let .success(res):
                var sections: [TVTopShelfItemCollection<TVTopShelfSectionedItem>] = []
                if let page = res.data?.page {
                    for s in page.sections.items {
                        var items: [TVTopShelfSectionedItem] = []
                        if let itemSection = s.asItemSection {
                            for i in itemSection.items.items {
                                let item = TVTopShelfSectionedItem(identifier: i.id)
                                item.title = i.title
                                if let img = i.image {
                                    item.setImageURL(URL(string: img), for: .screenScale2x)
                                }
                                
                                if i.item.__typename == "Episode",
                                    let e = i.item.asEpisode {
                                    if let p = e.progress,
                                        p <= e.duration {
                                        item.playbackProgress = Double(e.duration) / Double(p)
                                    }
                                    let action = TVTopShelfAction(url: urlFor(episodeId: i.id))
                                    item.playAction = action
                                    item.displayAction = action
                                    items.append(item)
                                }
                            }
                            let col = TVTopShelfItemCollection(items: items)
                            col.title = s.title
                            sections.append(col)
                        }
                    }
                }
                completionHandler(TVTopShelfSectionedContent(sections: sections))
            case .failure:
                completionHandler(nil)
            }
        }
    }

}

func urlFor(episodeId: String) -> URL {
    var components = URLComponents()
    components.scheme = "bcc.media"
    components.path = "episode/\(episodeId)"
    
    return components.url!
}
