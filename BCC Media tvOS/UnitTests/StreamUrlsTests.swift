//
//  StreamUrlsTests.swift
//  unittests
//
//  Covers getPlayerUrl and StreamUrls in Utils/Episodes.swift.
//

import API
import XCTest

private typealias Stream = API.GetEpisodeStreamsQuery.Data.Episode.Stream

/// Builds a stream the way the API would return it, without going near the network.
private func stream(language: String?, url: String, type: API.StreamType) -> Stream {
    stream(language: language, url: url, type: GraphQLEnum(type))
}

private func stream(language: String?, url: String, type: GraphQLEnum<API.StreamType>) -> Stream {
    var fields: [String: AnyHashable] = [
        "__typename": "Stream",
        "url": url,
        "type": type,
    ]
    if let language = language {
        fields["videoLanguage"] = language
    }
    return Stream(_dataDict: DataDict(
        data: fields,
        fulfilledFragments: [ObjectIdentifier(Stream.self)]
    ))
}

/// A url the API should never send, but has to be survivable: `URL(string:)` rejects it.
private let brokenUrl = ""

final class GetPlayerUrlTests: XCTestCase {
    func testPrefersCmafOverEverythingElse() {
        let url = getPlayerUrl(streams: [
            stream(language: "no", url: "https://s.bcc.media/dash.mpd", type: .dash),
            stream(language: "no", url: "https://s.bcc.media/ts.m3u8", type: .hlsTs),
            stream(language: "no", url: "https://s.bcc.media/cmaf.m3u8", type: .hlsCmaf),
        ])
        XCTAssertEqual(url, URL(string: "https://s.bcc.media/cmaf.m3u8"))
    }

    func testPrefersTsOverDash() {
        let url = getPlayerUrl(streams: [
            stream(language: "no", url: "https://s.bcc.media/dash.mpd", type: .dash),
            stream(language: "no", url: "https://s.bcc.media/ts.m3u8", type: .hlsTs),
        ])
        XCTAssertEqual(url, URL(string: "https://s.bcc.media/ts.m3u8"))
    }

    /// A stream type the client doesn't know about — the server can add one at any time.
    func testFallsBackToTheFirstStreamOfAnUnknownType() {
        let url = getPlayerUrl(streams: [
            stream(language: "no", url: "https://s.bcc.media/other.m3u8", type: GraphQLEnum<API.StreamType>.unknown("webm")),
        ])
        XCTAssertEqual(url, URL(string: "https://s.bcc.media/other.m3u8"))
    }

    func testReturnsNilWithoutStreams() {
        XCTAssertNil(getPlayerUrl(streams: []))
    }

    func testReturnsNilForAnUnparseableUrl() {
        XCTAssertNil(URL(string: brokenUrl), "fixture must be unparseable")
        XCTAssertNil(getPlayerUrl(streams: [stream(language: "no", url: brokenUrl, type: .hlsCmaf)]))
    }
}

final class StreamUrlsTests: XCTestCase {
    func testMapsCmafStreamsByLanguage() {
        let urls = StreamUrls(streams: [
            stream(language: "no", url: "https://s.bcc.media/no.m3u8", type: .hlsCmaf),
            stream(language: "en", url: "https://s.bcc.media/en.m3u8", type: .hlsCmaf),
        ])
        XCTAssertEqual(urls.languages, ["en", "no"])
        XCTAssertEqual(urls.get(language: "no"), URL(string: "https://s.bcc.media/no.m3u8"))
        XCTAssertEqual(urls.get(language: "en"), URL(string: "https://s.bcc.media/en.m3u8"))
    }

    /// One bad url used to trap and take playback down for every language.
    func testSkipsStreamsWithAnUnparseableUrl() {
        XCTAssertNil(URL(string: brokenUrl), "fixture must be unparseable")

        let urls = StreamUrls(streams: [
            stream(language: "no", url: "https://s.bcc.media/no.m3u8", type: .hlsCmaf),
            stream(language: "de", url: brokenUrl, type: .hlsCmaf),
            stream(language: "en", url: "https://s.bcc.media/en.m3u8", type: .hlsCmaf),
        ])

        XCTAssertEqual(urls.languages, ["en", "no"])
        XCTAssertEqual(urls.get(language: "en"), URL(string: "https://s.bcc.media/en.m3u8"))
        // German falls back to the default stream rather than resolving to nothing.
        XCTAssertEqual(urls.get(language: "de"), URL(string: "https://s.bcc.media/no.m3u8"))
    }

    func testIgnoresNonCmafStreamsForLanguages() {
        let urls = StreamUrls(streams: [
            stream(language: "no", url: "https://s.bcc.media/no.m3u8", type: .hlsCmaf),
            stream(language: "en", url: "https://s.bcc.media/en.mpd", type: .dash),
            stream(language: "de", url: "https://s.bcc.media/de.m3u8", type: .hlsTs),
        ])
        XCTAssertEqual(urls.languages, ["no"])
    }

    func testIgnoresStreamsWithoutALanguage() {
        let urls = StreamUrls(streams: [
            stream(language: nil, url: "https://s.bcc.media/any.m3u8", type: .hlsCmaf),
        ])
        XCTAssertEqual(urls.languages, [])
        XCTAssertEqual(urls.get(language: nil), URL(string: "https://s.bcc.media/any.m3u8"))
    }

    func testFirstStreamWinsForADuplicateLanguage() {
        let urls = StreamUrls(streams: [
            stream(language: "no", url: "https://s.bcc.media/first.m3u8", type: .hlsCmaf),
            stream(language: "no", url: "https://s.bcc.media/second.m3u8", type: .hlsCmaf),
        ])
        XCTAssertEqual(urls.get(language: "no"), URL(string: "https://s.bcc.media/first.m3u8"))
    }

    func testUnknownAndMissingLanguagesUseTheDefaultStream() {
        let urls = StreamUrls(streams: [
            stream(language: "no", url: "https://s.bcc.media/no.m3u8", type: .hlsCmaf),
        ])
        XCTAssertEqual(urls.get(language: "sl"), URL(string: "https://s.bcc.media/no.m3u8"))
        XCTAssertEqual(urls.get(language: nil), URL(string: "https://s.bcc.media/no.m3u8"))
    }

    func testEmptyStreamsResolveToNothing() {
        let urls = StreamUrls(streams: [])
        XCTAssertEqual(urls.languages, [])
        XCTAssertNil(urls.get(language: "no"))
        XCTAssertNil(urls.get(language: nil))
    }
}
