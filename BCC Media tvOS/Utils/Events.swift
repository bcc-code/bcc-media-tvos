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
    var contentPodId: String
    var position: Int?
    var totalLength: Int
    var videoPlayer = "AVPlayer"
    var fullScreen = true
    var hasVideo = true

    init(sessionId: String, contentPodId: String, position: Int? = nil, totalLength: Int, videoPlayer: String = "AVPlayer", fullScreen: Bool = true, hasVideo: Bool = true) {
        self.sessionId = sessionId
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

class VideoPlayed: Event {
    static var eventName = "video_played"
    
    var videoId: String
    var referenceId: String
    
    init(videoId: String, referenceId: String) {
        self.videoId = videoId
        self.referenceId = referenceId
    }
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

        AppOptions.standard.rudder.writeKey = processInfo.environment["RUDDER_WRITE_KEY"] ?? CI.rudderWriteKey
        AppOptions.standard.rudder.dataPlaneUrl = processInfo.environment["RUDDER_DATAPLANE_URL"] ?? CI.rudderDataplaneURL

        let builder = RSConfigBuilder()
            .withDataPlaneUrl(AppOptions.rudder.dataPlaneUrl)

        client = RSClient.getInstance(AppOptions.rudder.writeKey, config: builder.build())
    }

    public static let standard = Events()

    public static var commonProperties: [String: String] {
        return [
            "channel": "tv",
            "appName": "bccm-tvos",
            "appLanguage": Locale.current.identifier,
            "releaseVersion": getVersion()
        ]
    }
    
    public static func trigger<T: Event>(_ event: T) {
        print(event)
        var dict = event.dictionary
        dict.merge(commonProperties){ (_, new) in new}
        standard.client.track(T.eventName, properties: dict)
    }

    public static func page(_ pageCode: String) {
        standard.client.screen(pageCode, properties: commonProperties)
    }

    func identify() async {
        guard let userId = AppOptions.user.anonymousId else {
            return
        }

        var traits = [String: Any]()
        traits["tv"] = true
        traits["ageGroup"] = AppOptions.user.ageGroup
        traits["country"] = AppOptions.user.countryISOCode
        traits["churchId"] = AppOptions.user.churchId
        traits["gender"] = AppOptions.user.gender

        client.identify(userId, traits: traits)
    }

    public static let sessionId = standard.client.sessionId
}
