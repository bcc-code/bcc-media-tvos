import Foundation
import XCTest

final class MainUITest: XCTestCase {
    // This method is called before the invocation of each test method in the class.
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // This method is called after the invocation of each test method in the class.
    override func tearDownWithError() throws {}

    @MainActor
    func testOpenPlayer() async throws {
        let app = XCUIApplication()
        app.launchEnvironment = [
            "UNLEASH_URL": "https://fake.url/api/frontend",
            "UNLEASH_CLIENT_KEY": "abc",
        ]
        app.launch()
        
        let loginButton = app.buttons["Log in"]
        if loginButton.waitForExistence(timeout: 30) {
            XCTAssert(loginButton.hasFocus)
            XCUIRemote.shared.press(.select)
        } else {
            takeScreenshot(name: "LoginButtonNotFound")
            XCTFail("Login button not found")
        }

        let loginCode = app.staticTexts["LoginCode"]
        if loginCode.waitForExistence(timeout: 30) {
            XCTAssertNotNil(loginCode.label, "LoginCode is nil")
        } else {
            takeScreenshot(name: "LoginCodeNotFound")
            XCTFail("Login code not found")
        }
        
        print(app.debugDescription)
        takeScreenshot(name: "BeforeLogin")

        let loginResult = await loginUserWithDeviceCode(deviceCode: loginCode.label)
        if !loginResult {
            takeScreenshot(name: "LoginFailed")
            XCTFail("Login failed")
            return
        }

        // Wait for a real element rather than guessing how long the front page takes. Episodes only:
        // a page or study-topic card opens a subpage, which has no play button.
        let episodeCard = app.buttons
            .matching(NSPredicate(format: "identifier BEGINSWITH %@", "SectionItem-episode-"))
            .firstMatch
        guard episodeCard.waitForExistence(timeout: 60) else {
            takeScreenshot(name: "NoEpisodeCardOnFrontPage")
            XCTFail("No episode card appeared on the front page")
            return
        }
        guard focus(episodeCard, using: .down) else {
            takeScreenshot(name: "EpisodeCardNotFocusable")
            XCTFail("Could not move focus to an episode card")
            return
        }
        XCUIRemote.shared.press(.select)

        let playButton = app.buttons["PlayEpisode"]
        guard playButton.waitForExistence(timeout: 30) else {
            takeScreenshot(name: "PlayButtonNotFound")
            XCTFail("Play button not found")
            return
        }
        guard focus(playButton, using: .up) else {
            takeScreenshot(name: "PlayButtonNotFocusable")
            XCTFail("Could not move focus to the play button")
            return
        }
        XCUIRemote.shared.press(.select)

        // Multi-language episodes show a language picker first, and EpisodePlayer does not create the
        // player until one is chosen — so without this the status probe never appears at all.
        let originalLanguage = app.buttons["VideoLanguage-original"]
        if originalLanguage.waitForExistence(timeout: 10) {
            guard focus(originalLanguage, using: .down) else {
                takeScreenshot(name: "LanguageNotFocusable")
                XCTFail("Language picker appeared but focus never reached it")
                return
            }
            XCUIRemote.shared.press(.select)
        }

        let statusProbe = app.staticTexts["CurrentPlayerStatus"]
        guard statusProbe.waitForExistence(timeout: 30) else {
            takeScreenshot(name: "PlayerStatusNotFound")
            XCTFail("Player status probe not found")
            return
        }

        // The probe mounts with the player view, which is before play() has buffered — so wait for
        // the state instead of sampling it once. "Playing" is PlaybackStatus.playing's raw value;
        // UI tests run out of process and cannot import the app's types.
        let isPlaying = expectation(for: NSPredicate(format: "label == %@", "Playing"),
                                   evaluatedWith: statusProbe)
        if XCTWaiter.wait(for: [isPlaying], timeout: 60) != .completed {
            takeScreenshot(name: "PlayerNeverStartedPlaying")
            XCTFail("Player never reached Playing (last reported: \(statusProbe.label))")
        }
    }

    /// tvOS has no `tap()` — focus has to be walked with the remote. Bounded, so a layout change
    /// fails with a clear message instead of leaving focus somewhere arbitrary.
    private func focus(_ element: XCUIElement, using button: XCUIRemote.Button, maxPresses: Int = 12) -> Bool {
        for _ in 0 ..< maxPresses {
            if element.hasFocus { return true }
            XCUIRemote.shared.press(button)
        }
        return element.hasFocus
    }

    func takeScreenshot(name: String = "FailureScreenshot", lifetime: XCTAttachment.Lifetime = .keepAlways) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = lifetime
        add(attachment)
    }
}

private func loginUserWithDeviceCode(deviceCode: String) async -> Bool {
    let apiKey = ProcessInfo.processInfo.environment["LOGIN_API_KEY"] ?? ""
    if apiKey == "" {
        debugPrint("no api key!!")
        return false
    }

    let autoLoginHost = (ProcessInfo.processInfo.environment["AUTOLOGIN_HOST"] ?? "").replacingOccurrences(of: "\\/", with: "/")
    if autoLoginHost == "" {
        debugPrint("no host!!")
        return false
    }

    let rawUrl = autoLoginHost + "/confirm?user_code=\(deviceCode)&api_key=\(apiKey)"
    guard let url = URL(string: rawUrl) else {
        debugPrint("invalid url!!")
        return false
    }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    do {
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { return false }
        // Handle successful response
        return true
    } catch {
        // Handle error
        debugPrint(error)
        return false
    }
}
