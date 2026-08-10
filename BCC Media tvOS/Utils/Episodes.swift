//
//  Episodes.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 03/05/2023.
//

import Foundation
import API

/// Stream types we can play, best first.
private let preferredStreamTypes = [API.StreamType.hlsCmaf, API.StreamType.hlsTs, API.StreamType.dash]

/// The first stream matching the most preferred type available, falling back to any stream at all.
func getPlayerUrl(streams: [API.GetEpisodeStreamsQuery.Data.Episode.Stream]) -> URL? {
    let preferred = preferredStreamTypes.lazy
        .compactMap { type in streams.first { $0.type == type } }
        .first

    guard let stream = preferred ?? streams.first else {
        return nil
    }
    return URL(string: stream.url)
}

class StreamUrls {
    private var urls: [String:URL] = [:]
    
    private var _default: URL?
    
    public func get(language: String?) -> URL? {
        if let l = language, urls.keys.contains(l) {
            return urls[l]
        }
        return _default
    }
    
    public var languages: [String] {
        urls.keys.sorted()
    }
    
    public init(streams: [API.GetEpisodeStreamsQuery.Data.Episode.Stream]) {
        _default = getPlayerUrl(streams: streams)

        for stream in streams {
            // A malformed url used to trap here. Skipping the stream instead just means that language
            // is not offered, and `_default` still plays.
            guard stream.type == API.StreamType.hlsCmaf,
                  let language = stream.videoLanguage,
                  urls[language] == nil,
                  let url = URL(string: stream.url)
            else {
                continue
            }
            urls[language] = url
        }
    }
}

