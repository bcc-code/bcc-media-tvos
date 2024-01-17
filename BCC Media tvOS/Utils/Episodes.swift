//
//  Episodes.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 03/05/2023.
//

import Foundation
import API

func getPlayerUrl(streams: [API.GetEpisodeStreamsQuery.Data.Episode.Stream]) -> URL? {
    let types = [API.StreamType.hlsCmaf, API.StreamType.hlsTs, API.StreamType.dash]
    var index = 0
    var stream = streams.first(where: { $0.type == types[index] })
    while stream == nil, (types.count - 1) > index {
        index += 1
        stream = streams.first(where: { $0.type == types[index] })
    }
    if stream == nil {
        stream = streams.first
    }
    if let stream = stream {
        return URL(string: stream.url)
    }
    return nil
}
