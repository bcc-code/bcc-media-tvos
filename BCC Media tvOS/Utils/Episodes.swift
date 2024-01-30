//
//  Episodes.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 03/05/2023.
//

import Foundation
import API

fileprivate let types = [API.StreamType.hlsCmaf, API.StreamType.hlsTs, API.StreamType.dash]

func getPlayerUrl(streams: [API.GetEpisodeStreamsQuery.Data.Episode.Stream]) -> URL? {
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
            if stream.type != API.StreamType.hlsCmaf {
                continue
            }
            if stream.videoLanguage == nil {
                continue
            }
            let l = stream.videoLanguage!
            
            if urls.keys.contains(l) {
                continue
            }
        
            urls[l] = URL(string: stream.url)!
        }
    }
}

