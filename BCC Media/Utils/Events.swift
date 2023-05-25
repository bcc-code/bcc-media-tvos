//
//  Events.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 15/05/2023.
//

import Foundation
import Rudder

protocol Event: Encodable {
    static var eventName: String { get }
}

extension Event {
    var dictionary: [String: Any] {
        return (try? JSONSerialization.jsonObject(with: JSONEncoder().encode(self))) as? [String: Any] ?? [:]
    }
}

struct SectionClicked: Event {
    static let eventName = "section_clicked"

    var sectionId: String
    var sectionName: String
    var sectionPosition: Int
    var sectionType: String
    var elementPosition: Int
    var elementType: String
    var elementId: String
    var elementName: String
    var pageCode: String
}

struct AudioonlyClicked: Event {
    static let eventName = "audioonly_clicked"

    var audioOnly: Bool
}

struct CalendardayClicked: Event {
    static let eventName = "calendarday_clicked"

    var pageCode: String
    var calendarView: String
    var calendarDate: String
}

struct SearchPerformed: Event {
    static let eventName = "search_performed"

    var searchText: String
    var searchLatency: Int
    var searchResultCount: Int
}

struct LanguageChanged: Event {
    static let eventName = "language_changed"

    var pageCode: String
    var languageFrom: String
    var languageTo: String
}

class VideoEvent {
    var sessionId: String
    var livestream: Bool
    var contentPodId: String
    var position: Int?
    var totalLength: Int
    var videoPlayer = "AVPlayer"
    var fullScreen = true
    var hasVideo = true
    
    init(sessionId: String, livestream: Bool, contentPodId: String, position: Int? = nil, totalLength: Int, videoPlayer: String = "AVPlayer", fullScreen: Bool = true, hasVideo: Bool = true) {
        self.sessionId = sessionId
        self.livestream = livestream
        self.contentPodId = contentPodId
        self.position = position
        self.totalLength = totalLength
        self.videoPlayer = videoPlayer
        self.fullScreen = fullScreen
        self.hasVideo = hasVideo
    }
}

class PlaybackStarted: VideoEvent, Event {
    static var eventName = "playback_started"
}

class PlaybackPaused: VideoEvent, Event {
    static var eventName = "playback_paused"
}

struct Events {
    private let client = RSClient.sharedInstance()

    private init() {
        let config = RSConfig(writeKey: AppOptions.rudder.writeKey)
            .dataPlaneURL(AppOptions.rudder.dataPlaneUrl)
//            .trackLifecycleEvents(true)
//            .recordScreenViews(true)

        client.configure(with: config)
    }

    public static let standard = Events()

    public static func trigger<T: Event>(_ event: T) {
        standard.client.track(T.eventName, properties: event.dictionary)
    }
    
    public static func page(_ pageCode: String) {
        standard.client.screen(pageCode)
    }
}
