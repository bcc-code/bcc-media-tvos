//
//  ItemSection.swift
//
//  Created by Fredrik Vedvik on 10/03/2023.
//

import API
import SwiftUI

let previewItems: [Item] = [
    Item(id: "10", title: "Another Item", description: "description", image: "https://brunstadtv.imgix.net/92a64b64-1f82-42c2-85f2-8a7ff39b1f90.jpg", duration: 200, progress: 120, type: .episode),
    Item(id: "16", title: "Another Item with a longer title for debugs", description: "description", image: "https://brunstadtv.imgix.net/92a64b64-1f82-42c2-85f2-8a7ff39b1f90.jpg", duration: 240, type: .episode),
    Item(id: "12", title: "Another Item", description: "description", image: "https://brunstadtv.imgix.net/92a64b64-1f82-42c2-85f2-8a7ff39b1f90.jpg", duration: 5000, progress: 2140, type: .episode),
    Item(id: "1", title: "Another Item", description: "description", image: "https://brunstadtv.imgix.net/92a64b64-1f82-42c2-85f2-8a7ff39b1f90.jpg", type: .episode),
    Item(id: "20", title: "Another Item", description: "description", image: "https://brunstadtv.imgix.net/92a64b64-1f82-42c2-85f2-8a7ff39b1f90.jpg", type: .episode),
    Item(id: "11", title: "Another Item", description: "description", image: "https://brunstadtv.imgix.net/92a64b64-1f82-42c2-85f2-8a7ff39b1f90.jpg", type: .episode),
]

enum ItemType: String {
    case episode
    case show
    case page
    case topic
    case season
    case playlist
    case unsupported
}

typealias ClickItem = (Item, API.EpisodeContext?) async -> Void

typealias SectionClickItem = (Item) async -> Void

struct Item: Identifiable {
    var id: String
    var title: String
    var showTitle: String?
    var seasonTitle: String?
    var description: String
    var image: String?
    var duration: Int?
    var progress: Int?

    var type: ItemType

    var locked = false

    var index = 0
    var sectionIndex = 0
}

struct ItemTitle: View {
    var item: Item

    init(_ item: Item) {
        self.item = item
    }

    var body: some View {
        VStack(alignment: .leading) {
            if let seasonTitle = item.seasonTitle, let showTitle = item.showTitle {
                HStack {
                    Text(showTitle).font(.barlowCaption).foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    Spacer()
                    Text(seasonTitle).font(.barlowCaption).foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }.frame(maxWidth: .infinity)
            }
            Text(item.title).font(.barlowCaption)
        }
    }
}

struct SectionTitle: View {
    var title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title).font(.barlowTitle).frame(maxWidth: .infinity, alignment: .leading)
    }
}

func mapToItem(_ item: API.ItemSectionFragment.Items.Item) -> Item {
    var t: ItemType
    var locked = false
    var duration: Int? = nil
    var progress: Int? = nil
    switch item.item.__typename {
    case API.Objects.Show.typename:
        t = .show
    case API.Objects.Episode.typename:
        t = .episode
        if let e = item.item.asEpisode {
            locked = e.locked
            duration = e.duration
            progress = e.progress
        }
    case API.Objects.Page.typename:
        t = .page
    case API.Objects.Season.typename:
        t = .season
    case API.Objects.StudyTopic.typename:
        t = .topic
    case API.Objects.Playlist.typename:
        t = .playlist
    default:
        t = .unsupported
    }
    return Item(
        id: item.id,
        title: item.title,
        description: item.description,
        image: item.image,
        duration: duration,
        progress: progress,
        type: t,
        locked: locked
    )
}

func mapToItems(_ items: API.ItemSectionFragment.Items, sectionIndex: Int) -> [Item] {
    var result: [Item] = []

    for (index, item) in items.items.enumerated() {
        var i = mapToItem(item)
        i.index = index
        i.sectionIndex = sectionIndex
        if i.type != .unsupported {
            result.append(i)
        }
    }

    return result
}

struct LoadingOverlay: View {
    var loading: Bool

    init(_ loading: Bool) {
        self.loading = loading
    }

    var body: some View {
        ZStack {
            if loading {
                Color.black.opacity(0.5).transition(.opacity)
                ProgressView()
            }
        }
    }
}
