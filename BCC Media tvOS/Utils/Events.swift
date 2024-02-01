//
//  Events.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 15/05/2023.
//

import Rudder
import Foundation

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
    var searchLatency: Double
    var searchResultCount: Int
}

struct SearchresultClicked: Event {
    static let eventName = "searchresult_clicked"

    var searchText: String
    var elementPosition: Int
    var elementType: String
    var elementId: String
    var group: String
}

struct LanguageChanged: Event {
    static let eventName = "language_changed"

    var pageCode: String
    var languageFrom: String
    var languageTo: String
}

struct ApplicationOpened: Event {
    static let eventName = "application_opened"

    var reason: String
    var coldStart: Bool
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

class ErrorOccured: Event {
    static var eventName = "tvos_error"

    var error: String

    init(error: String) {
        self.error = error
    }
}

struct Events {
    private var client: RSClient

    private init() {
        let processInfo = ProcessInfo.processInfo

        AppOptions.standard.rudder.writeKey = processInfo.environment["RUDDER_WRITEKEY"] ?? CI.rudderWriteKey
        AppOptions.standard.rudder.dataPlaneUrl = processInfo.environment["RUDDER_DATAPLANEURL"] ?? CI.rudderDataplaneURL
        
        let builder: RSConfigBuilder = RSConfigBuilder()
            .withDataPlaneUrl(AppOptions.rudder.dataPlaneUrl)

        client = RSClient.getInstance(AppOptions.rudder.writeKey, config: builder.build())
    }

    public static let standard = Events()

    public static func trigger<T: Event>(_ event: T) {
        print(event)
        
        var dict = event.dictionary
        dict["channel"] = "tv"
        dict["appLanguage"] = Locale.current.identifier
        dict["releaseVersion"] = getVersion()
        
        standard.client.track(T.eventName, properties: dict)
    }

    public static func page(_ pageCode: String) {
        standard.client.screen(pageCode)
    }
}
