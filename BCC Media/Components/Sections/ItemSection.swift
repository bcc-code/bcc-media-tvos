//
//  ItemSection.swift
//
//  Created by Fredrik Vedvik on 10/03/2023.
//

import SwiftUI

let previewItems: [Item] = [
    Item(id: "10", title: "Another Item", description: "description", image: "https://brunstadtv.imgix.net/92a64b64-1f82-42c2-85f2-8a7ff39b1f90.jpg", duration: 200, progress: 120),
    Item(id: "16", title: "Another Item with a longer title for debugs", description: "description", image: "https://brunstadtv.imgix.net/92a64b64-1f82-42c2-85f2-8a7ff39b1f90.jpg", duration: 240),
    Item(id: "12", title: "Another Item", description: "description", image: "https://brunstadtv.imgix.net/92a64b64-1f82-42c2-85f2-8a7ff39b1f90.jpg", duration: 5000, progress: 2140),
    Item(id: "1", title: "Another Item", description: "description", image: "https://brunstadtv.imgix.net/92a64b64-1f82-42c2-85f2-8a7ff39b1f90.jpg"),
    Item(id: "20", title: "Another Item", description: "description", image: "https://brunstadtv.imgix.net/92a64b64-1f82-42c2-85f2-8a7ff39b1f90.jpg"),
    Item(id: "11", title: "Another Item", description: "description", image: "https://brunstadtv.imgix.net/92a64b64-1f82-42c2-85f2-8a7ff39b1f90.jpg"),
]

enum ItemType: String {
    case episode
    case show
    case page
    case topic
    case season
}

typealias ClickItem = (Item, API.EpisodeContext?) async -> Void

typealias SectionClickItem = (Item) async -> Void

struct Item: Identifiable {
    var id: String
    var title: String
    var description: String
    var image: String?
    var duration: Int?
    var progress: Int?

    var type: ItemType = .episode

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
            Text(item.title).font(.caption2)
        }
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
    default:
        t = .episode
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
        result.append(i)
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
