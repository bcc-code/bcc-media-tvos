//
//  ContentProvider.swift
//  Top Shelf
//
//  Created by Fredrik Vedvik on 25/04/2023.
//

import TVServices

let authenticationProvider = AuthenticationProvider { error in
    print(error)
}

let apolloClient = ApolloClientFactory("https://api.brunstad.tv/query", tokenFactory: authenticationProvider.getAccessToken).NewClient()

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
                                    item.playAction = TVTopShelfAction(url: urlFor(episodeId: i.id, withPlay: true))
                                    item.displayAction = TVTopShelfAction(url: urlFor(episodeId: i.id, withPlay: false))
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

func urlFor(episodeId: String, withPlay: Bool) -> URL {
    var components = URLComponents()
    components.scheme = "bcc.media"
    components.path = "episode/\(episodeId)"
    if withPlay {
        components.queryItems = [
            URLQueryItem(name: "play", value: nil),
        ]
    }

    return components.url!
}
