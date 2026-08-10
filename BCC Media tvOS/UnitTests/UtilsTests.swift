//
//  UtilsTests.swift
//  unittests
//
//  Covers String.splitAroundPlaceholder and getQRCodeData in Utils.swift.
//

import XCTest

final class StringAroundTests: XCTestCase {
    func testSplitsAroundThePlaceholder() {
        let (before, after) = "Contact us at $email for help".splitAroundPlaceholder("$email")
        XCTAssertEqual(before, "Contact us at ")
        XCTAssertEqual(after, " for help")
    }

    /// A template ending in the placeholder has nothing after it — the old
    /// `split(separator:)` returned a single element here, so reading `[1]` trapped.
    func testAfterIsEmptyWhenPlaceholderIsLast() {
        let (before, after) = "Read our privacy policy at $url".splitAroundPlaceholder("$url")
        XCTAssertEqual(before, "Read our privacy policy at ")
        XCTAssertEqual(after, "")
    }

    func testBeforeIsEmptyWhenPlaceholderIsFirst() {
        let (before, after) = "$email is our address".splitAroundPlaceholder("$email")
        XCTAssertEqual(before, "")
        XCTAssertEqual(after, " is our address")
    }

    /// A translation that dropped the placeholder must still render its own text.
    func testMissingPlaceholderYieldsTheWholeString() {
        let (before, after) = "Kontakt oss".splitAroundPlaceholder("$email")
        XCTAssertEqual(before, "Kontakt oss")
        XCTAssertEqual(after, "")
    }

    /// `split(separator:)` dropped empty segments, so a repeated placeholder shifted the
    /// indices. Only the first occurrence is a split point.
    func testOnlyTheFirstOccurrenceIsASplitPoint() {
        let (before, after) = "$email and $email".splitAroundPlaceholder("$email")
        XCTAssertEqual(before, "")
        XCTAssertEqual(after, " and $email")
    }

    func testEmptyStringIsHandled() {
        let (before, after) = "".splitAroundPlaceholder("$url")
        XCTAssertEqual(before, "")
        XCTAssertEqual(after, "")
    }

    /// SignIn splits a two-placeholder template by chaining: the second lookup runs on the
    /// tail of the first.
    func testChainedPlaceholdersSplitTheTail() {
        let template = "Or go to: $url and enter this code: $code"
        let (beforeUrl, afterUrl) = template.splitAroundPlaceholder("$url")
        XCTAssertEqual(beforeUrl, "Or go to: ")
        XCTAssertEqual(afterUrl.splitAroundPlaceholder("$code").before, " and enter this code: ")
    }

    /// Composing the parts back together must reproduce the template.
    func testPartsRecomposeIntoTheTemplate() {
        let template = "Skriv til $email hvis du har spørsmål"
        let (before, after) = template.splitAroundPlaceholder("$email")
        XCTAssertEqual(before + "$email" + after, template)
    }
}

final class QRCodeTests: XCTestCase {
    func testGeneratesPngDataForAsciiText() {
        let data = getQRCodeData(text: "https://bcc.media/login?code=ABCD")
        XCTAssertNotNil(data)
        // PNG magic number.
        XCTAssertEqual(data?.prefix(4).map { $0 }, [0x89, 0x50, 0x4E, 0x47])
    }

    /// Non-ASCII text can't be encoded for the generator. It used to force-unwrap its way
    /// to a crash; now it just declines to produce an image.
    func testReturnsNilForTextThatCannotBeEncoded() {
        XCTAssertNil(getQRCodeData(text: "kjærlighet"))
    }
}
