//
//  ContentProvider.swift
//  Top Shelf
//
//  Created by Fredrik Vedvik on 25/04/2023.
//

import TVServices

let authenticationProvider = AuthenticationProvider()

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
                            var imageShape: TVTopShelfSectionedItem.ImageShape

                            switch s.__typename {
                            case "IconSection":
                                imageShape = .square
                            case "PosterSection", "PosterGridSection":
                                imageShape = .poster
                            default:
                                imageShape = .hdtv
                            }

                            for i in itemSection.items.items {
                                let item = TVTopShelfSectionedItem(identifier: i.id)
                                item.title = i.title
                                if let img = i.image {
                                    item.setImageURL(URL(string: img), for: .screenScale2x)
                                }

                                if i.item.__typename == "Episode",
                                   let e = i.item.asEpisode
                                {
                                    if let p = e.progress,
                                       p <= e.duration
                                    {
                                        item.playbackProgress = Double(e.duration) / Double(p)
                                    }
                                    let action = TVTopShelfAction(url: urlFor(episodeId: i.id))
                                    item.playAction = action
                                    item.displayAction = action
                                    item.imageShape = imageShape
                                    items.append(item)
                                }
                            }
                            let col = TVTopShelfItemCollection(items: items)
                            col.title = s.title
                            sections.append(col)
                        }
                    }
                }
                let content = TVTopShelfSectionedContent(sections: sections)

                completionHandler(content)
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
