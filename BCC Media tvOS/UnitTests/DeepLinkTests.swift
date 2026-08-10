//
//  DeepLinkTests.swift
//  unittests
//
//  Covers parseEpisodeDeepLink in Utils/DeepLink.swift.
//

import XCTest

final class DeepLinkTests: XCTestCase {
    private func parse(_ string: String) -> EpisodeDeepLink? {
        guard let url = URL(string: string) else {
            XCTFail("\(string) is not a URL")
            return nil
        }
        return parseEpisodeDeepLink(url)
    }

    func testParsesEpisodeLink() {
        XCTAssertEqual(parse("bcc.media:///episode/1234"), EpisodeDeepLink(episodeId: "1234", play: false))
    }

    func testParsesHttpEpisodeLink() {
        XCTAssertEqual(parse("https://bcc.media/episode/1234"), EpisodeDeepLink(episodeId: "1234", play: false))
    }

    func testPlayFlagIsSetByThePlayQueryItem() {
        XCTAssertEqual(parse("bcc.media:///episode/1234?play"), EpisodeDeepLink(episodeId: "1234", play: true))
    }

    /// `play` is a marker, not a boolean: any value, in any position, means play.
    func testPlayFlagIgnoresValueAndPosition() {
        XCTAssertEqual(parse("bcc.media:///episode/1234?t=10&play=false"), EpisodeDeepLink(episodeId: "1234", play: true))
    }

    func testUnrelatedQueryItemsDoNotSetThePlayFlag() {
        XCTAssertEqual(parse("bcc.media:///episode/1234?autoplay=true"), EpisodeDeepLink(episodeId: "1234", play: false))
    }

    func testTrailingSlashIsIgnored() {
        XCTAssertEqual(parse("bcc.media:///episode/1234/"), EpisodeDeepLink(episodeId: "1234", play: false))
    }

    /// Extra path components are not something we know how to open, but the episode id is
    /// still the actionable part of the link.
    func testExtraPathComponentsStillResolveToTheId() {
        XCTAssertEqual(parse("bcc.media:///episode/1234/season/5"), EpisodeDeepLink(episodeId: "1234", play: false))
    }

    /// An episode path with no id used to trap on `parts[1]`.
    func testEpisodeLinkWithoutAnIdIsIgnored() {
        XCTAssertNil(parse("bcc.media:///episode"))
        XCTAssertNil(parse("bcc.media:///episode/"))
        XCTAssertNil(parse("https://bcc.media/episode/"))
    }

    /// An empty path used to trap on `parts[0]`.
    func testLinkWithoutAPathIsIgnored() {
        XCTAssertNil(parse("bcc.media://"))
        XCTAssertNil(parse("https://bcc.media/"))
    }

    func testOtherPathsAreIgnored() {
        XCTAssertNil(parse("bcc.media:///page/frontpage"))
        XCTAssertNil(parse("https://bcc.media/show/1234"))
    }

    /// Documents existing behaviour: the episode segment is read from the *path*, so a
    /// two-slash link — where "episode" parses as the host and "1234" as the whole path —
    /// is not recognised.
    func testEpisodeInTheHostPositionIsNotRecognised() {
        XCTAssertNil(parse("bcc.media://episode/1234"))
    }
}
