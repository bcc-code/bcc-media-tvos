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

// Structs, not a shared `VideoEvent` superclass. These were subclasses of a plain (non-Encodable)
// `VideoEvent`, and `Event` requires `Encodable` — so Swift synthesised an encoder covering only each
// subclass's *own* stored properties, of which there were none. Both events serialised as `{}` and
// reached Rudder carrying nothing but `commonProperties`: no session, content id, position or duration.
//
// Making `VideoEvent` conform to `Encodable` would fix today's symptom but leave the trap armed — add
// one stored property to a subclass later and Swift synthesises a fresh `encode(to:)` that covers only
// that property and never calls `super`, silently dropping the inherited fields again. A struct cannot
// be subclassed, so the failure mode is gone rather than postponed. It also matches every other event
// in this file.
//
// The duplicated field list is deliberate: this is a wire format, and the two events are independently
// versioned by whatever consumes them.

struct PlaybackStarted: Event {
    static let eventName = "playback_started"

    var sessionId: String
    var contentPodId: String
    var position: Int?
    var totalLength: Int
    var videoPlayer = "AVPlayer"
    var fullScreen = true
    var hasVideo = true
}

struct PlaybackPaused: Event {
    static let eventName = "playback_paused"

    var sessionId: String
    var contentPodId: String
    var position: Int?
    var totalLength: Int
    var videoPlayer = "AVPlayer"
    var fullScreen = true
    var hasVideo = true
}

// These two encoded correctly — they declare their own fields and conform directly, so nothing was
// hidden in a non-Encodable superclass. Converted anyway so that "every Event is a struct" holds as an
// invariant: that is the property making the empty-payload bug above structurally impossible rather than
// merely absent today. The memberwise initialisers match the explicit ones they replace.

struct VideoPlayed: Event {
    static let eventName = "video_played"

    var videoId: String
    var referenceId: String
}

struct ErrorOccured: Event {
    static let eventName = "tvos_error"

    var error: String
}

struct Events {
    private var client: RSClient

    private init() {
        // Reads `AppOptions.rudder` directly — it resolves env/CI on access, so this no longer has
        // to populate it first. That mattered: `AppOptions.standard.sessionId` reaches back into
        // `Events.sessionId`, so a getter was transitively writing to `AppOptions.standard`.
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
