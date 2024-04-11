import Foundation
import XCTest

final class MainUITest: XCTestCase {
    // This method is called before the invocation of each test method in the class.
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // This method is called after the invocation of each test method in the class.
    override func tearDownWithError() throws {}

    func testOpenLivestream() async throws {
        let app = XCUIApplication()
        app.launchEnvironment = [
            "UNLEASH_URL": "https://fake.url/api/frontend",
            "UNLEASH_CLIENT_KEY": "abc",
        ]
        DispatchQueue.main.sync {
            app.launch()
        }

        sleep(3)

        XCTAssert(XCUIApplication().buttons["Log in"].hasFocus)
        XCUIRemote.shared.press(.select)

        sleep(10)
        let loginCode = app.staticTexts["LoginCode"].label
        XCTAssertNotNil(loginCode)

        let loginResult = await loginUserWithDeviceCode(deviceCode: loginCode)
        XCTAssertEqual(loginResult, true, "Login failed")

        sleep(15)

        XCUIRemote.shared.press(.up)
        XCUIRemote.shared.press(.down)
        XCUIRemote.shared.press(.down)

        let otherElements = app.scrollViews.otherElements
        XCUIRemote.shared.press(.select)
        XCUIRemote.shared.press(.up)
        sleep(5)
        XCTAssert(otherElements.buttons["Play"].hasFocus)
        XCUIRemote.shared.press(.select)
        sleep(10)

        let playingLabel = app.staticTexts["CurrentPlayerStatus"]
        XCTAssertEqual(playingLabel.label, "Playing", "Player status is not correct.")
    }
}

private func loginUserWithDeviceCode(deviceCode: String) async -> Bool {
    let apiKey = ProcessInfo.processInfo.environment["LOGIN_API_KEY"] ?? ""
    if apiKey == "" {
        debugPrint("no api key!!")
        return false
    }

    let autoLoginHost = ProcessInfo.processInfo.environment["AUTOLOGIN_HOST"] ?? ""
    if autoLoginHost == "" {
        debugPrint("no host!!")
        return false
    }

    let rawUrl = autoLoginHost + "/confirm?user_code=\(deviceCode)&api_key=\(apiKey)"
    guard let url = URL(string: rawUrl) else {
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
