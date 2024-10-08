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
        
        let loginButton = XCUIApplication().buttons["Log in"]
        if loginButton.waitForExistence(timeout: 3) {
            XCTAssert(loginButton.hasFocus)
            XCUIRemote.shared.press(.select)
        }

        let loginCode = app.staticTexts["LoginCode"]
        if loginCode.waitForExistence(timeout: 10) {
            XCTAssertNotNil(loginCode.label)
        }

        let loginResult = await loginUserWithDeviceCode(deviceCode: loginCode.label)
        XCTAssertEqual(loginResult, true, "Login failed")

        sleep(15)

        XCUIRemote.shared.press(.up)
        XCUIRemote.shared.press(.down)
        XCUIRemote.shared.press(.down)
        XCUIRemote.shared.press(.select)
        XCUIRemote.shared.press(.up)

        let otherElements = app.scrollViews.otherElements
        
        let playButton = otherElements.buttons["Play"]
        if playButton.waitForExistence(timeout: 5) {
            XCTAssert(playButton.hasFocus)
            XCUIRemote.shared.press(.select)
        }

        let playingLabel = app.staticTexts["CurrentPlayerStatus"]
        if playingLabel.waitForExistence(timeout: 10) {
            XCTAssertEqual(playingLabel.label, "Playing", "Player status is not correct.")
        }
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
