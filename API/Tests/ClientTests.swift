import Apollo
import ApolloAPI
import Foundation
import XCTest

@testable import API

/// A `NetworkTransport` that answers every operation with one canned response body.
///
/// Apollo 1.8 ships no mock transport we can consume: `MockNetworkTransport` lives in its unpublished
/// internal test helpers, and the `ApolloTestSupport` product only holds helpers for generated test
/// mocks, which this project does not generate. Handing the body to `GraphQLResponse` rather than
/// building a `GraphQLResult` by hand keeps these tests on the same parser production uses — which
/// matters here, because what is under test is how `getAsync` treats what that parser produces.
private final class StubTransport: NetworkTransport {
    let clientName = "APIUnitTests"
    let clientVersion = "1"

    private let body: JSONObject

    init(body: JSONObject) {
        self.body = body
    }

    func send<Operation: GraphQLOperation>(
        operation: Operation,
        cachePolicy _: CachePolicy,
        // Qualified: the schema declares its own `UUID` scalar as a typealias for String.
        contextIdentifier _: Foundation.UUID?,
        context _: (any RequestContext)?,
        callbackQueue: DispatchQueue,
        completionHandler: @escaping (Result<GraphQLResult<Operation.Data>, any Error>) -> Void
    ) -> any Cancellable {
        let response = GraphQLResponse(operation: operation, body: body)
        callbackQueue.async {
            completionHandler(Result { try response.parseResultFast() })
        }
        return EmptyCancellable()
    }
}

/// Collects what a fetch produced, from whichever thread produces it.
///
/// `ErrorReporter` is documented as making no assumption about its thread, and Apollo delivers the
/// fetch result on the callback queue rather than the caller's.
private final class Recorder {
    private let lock = NSLock()
    private var storedData: GetConfigQuery.Data?
    private var storedErrors: [any Error] = []

    func report(_ error: any Error) {
        lock.withLock { storedErrors.append(error) }
    }

    func record(_ data: GetConfigQuery.Data?) {
        lock.withLock { storedData = data }
    }

    var data: GetConfigQuery.Data? {
        lock.withLock { storedData }
    }

    var errors: [any Error] {
        lock.withLock { storedErrors }
    }
}

final class ClientTests: XCTestCase {
    /// Fetches `GetConfig` against a stubbed response body.
    ///
    /// Deliberately not an `async` test helper. `Client.getAsync` lets Apollo default to calling back
    /// on `DispatchQueue.main`, and an `async` test method leaves the main thread parked, so that
    /// callback would never run and the test would time out on a queue problem rather than on the
    /// behaviour it is checking. Waiting on an expectation services the main run loop instead.
    private func fetchConfig(respondingWith json: String) throws -> Recorder {
        let body = try XCTUnwrap(
            JSONSerialization.jsonObject(with: Data(json.utf8)) as? JSONObject,
            "the canned response body is not a JSON object"
        )
        let recorder = Recorder()
        let client = Client(
            apollo: ApolloClient(
                networkTransport: StubTransport(body: body),
                store: ApolloStore()
            ),
            reportError: recorder.report
        )

        let resumed = expectation(description: "getAsync resumed")
        Task {
            recorder.record(await client.getAsync(query: GetConfigQuery()))
            resumed.fulfill()
        }
        wait(for: [resumed], timeout: 5)

        return recorder
    }

    /// A response may legally carry both `data` and `errors` — here a nullable field's resolver failed
    /// while the rest of the query resolved. `getAsync` used to discard the whole response, so one
    /// errored nullable field blanked the caller's entire screen.
    func testPartialResponseKeepsItsData() throws {
        let recorder = try fetchConfig(respondingWith: """
        {
          "data": {
            "application": { "__typename": "Application", "page": null },
            "languages": ["no", "en"]
          },
          "errors": [
            { "message": "page resolver failed", "path": ["application", "page"] }
          ]
        }
        """)

        let data = try XCTUnwrap(recorder.data, "partial data was discarded")
        XCTAssertEqual(data.languages, ["no", "en"])
        XCTAssertNil(data.application.page)

        // Still reported: the caller gets its data and Sentry still hears about the failed field.
        XCTAssertEqual(recorder.errors.count, 1, "expected one report for the whole operation")
        let reported = try XCTUnwrap(recorder.errors.first as? GraphQLResponseError)
        XCTAssertEqual(reported.errors.count, 1)
        XCTAssertEqual(reported.description, "page resolver failed")
    }

    func testErrorsWithoutDataReturnNil() throws {
        let recorder = try fetchConfig(respondingWith: """
        {
          "errors": [
            { "message": "first failure" },
            { "message": "second failure" }
          ]
        }
        """)

        XCTAssertNil(recorder.data)
        // One report for the operation, not one per error.
        XCTAssertEqual(recorder.errors.count, 1)
        let reported = try XCTUnwrap(recorder.errors.first as? GraphQLResponseError)
        XCTAssertEqual(reported.description, "first failure; second failure")
    }

    func testCleanResponseReportsNothing() throws {
        let recorder = try fetchConfig(respondingWith: """
        {
          "data": {
            "application": {
              "__typename": "Application",
              "page": { "__typename": "Page", "code": "frontpage" }
            },
            "languages": ["no"]
          }
        }
        """)

        let data = try XCTUnwrap(recorder.data)
        XCTAssertEqual(data.application.page?.code, "frontpage")
        XCTAssertEqual(data.languages, ["no"])
        XCTAssertTrue(recorder.errors.isEmpty)
    }

    /// Neither `data` nor `errors`. Nothing to report and nothing to return, but the continuation must
    /// still resume — it once did not, and the caller hung for the life of the process.
    func testEmptyResponseResumesWithNil() throws {
        let recorder = try fetchConfig(respondingWith: "{}")

        XCTAssertNil(recorder.data)
        XCTAssertTrue(recorder.errors.isEmpty)
    }
}
