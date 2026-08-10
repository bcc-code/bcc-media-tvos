@testable import FeatureFlags
import UnleashProxyClientSwift
import XCTest

final class HeaderValueTests: XCTestCase {
    /// The format the backend parses (`brunstadtv/backend/utils/feature-flags.go`): comma separated
    /// `key` or `key:variantName`.
    func testEnabledToggleWithVariantSendsVariantName() {
        let toggles = [
            Toggle(name: "shorts", enabled: true, variant: Variant(name: "treatment", enabled: true))
        ]
        XCTAssertEqual(FeatureFlagsClient.headerValue(for: toggles), "shorts:treatment")
    }

    func testEnabledToggleWithoutVariantSendsBareKey() {
        let toggles = [Toggle(name: "shorts", enabled: true)]
        XCTAssertEqual(FeatureFlagsClient.headerValue(for: toggles), "shorts")
    }

    /// Unleash returns `{name: "disabled", enabled: false}` for a flag that has no variants; that
    /// must not leak into the header as `shorts:disabled`.
    func testDisabledVariantSendsBareKey() {
        let toggles = [
            Toggle(name: "shorts", enabled: true, variant: Variant(name: "disabled", enabled: false))
        ]
        XCTAssertEqual(FeatureFlagsClient.headerValue(for: toggles), "shorts")
    }

    /// The backend treats presence as truth, so a disabled toggle must be omitted entirely.
    func testDisabledToggleIsExcluded() {
        let toggles = [
            Toggle(name: "shorts", enabled: false, variant: Variant(name: "treatment", enabled: true)),
            Toggle(name: "search", enabled: true)
        ]
        XCTAssertEqual(FeatureFlagsClient.headerValue(for: toggles), "search")
    }

    func testOutputIsSortedByKey() {
        let toggles = [
            Toggle(name: "zeta", enabled: true),
            Toggle(name: "alpha", enabled: true, variant: Variant(name: "b", enabled: true)),
            Toggle(name: "mid", enabled: true)
        ]
        XCTAssertEqual(FeatureFlagsClient.headerValue(for: toggles), "alpha:b,mid,zeta")
    }

    func testEmptySetIsNilSoTheHeaderIsOmitted() {
        XCTAssertNil(FeatureFlagsClient.headerValue(for: []))
        XCTAssertNil(FeatureFlagsClient.headerValue(for: [Toggle(name: "shorts", enabled: false)]))
    }

    /// A name that contains the header's own separators would be mis-split by the backend.
    func testUnsafeToggleNameIsDropped() {
        let toggles = [
            Toggle(name: "bad,name", enabled: true),
            Toggle(name: "bad:name", enabled: true),
            Toggle(name: "with space", enabled: true),
            Toggle(name: "æøå", enabled: true),
            Toggle(name: "good", enabled: true)
        ]
        XCTAssertEqual(FeatureFlagsClient.headerValue(for: toggles), "good")
    }

    /// An unsafe variant name degrades to the bare key rather than dropping the flag.
    func testUnsafeVariantNameFallsBackToBareKey() {
        let toggles = [
            Toggle(name: "shorts", enabled: true, variant: Variant(name: "a,b", enabled: true))
        ]
        XCTAssertEqual(FeatureFlagsClient.headerValue(for: toggles), "shorts")
    }
}

final class SetupGuardTests: XCTestCase {
    /// `CI.swift` ships `"$UNLEASH_URL"`, which `envsubst` turns into `""` when the secret is
    /// missing. The SDK calls `fatalError` on either, so `setup` has to reject them first.
    func testInvalidConfigurationDisablesFlagsInsteadOfCrashing() {
        for (url, key) in [
            ("$UNLEASH_URL", "$UNLEASH_CLIENT_KEY"),
            ("", "abc"),
            ("nonsense", "abc"),
            ("https://unleash.example.com", "")
        ] {
            let client = FeatureFlagsClient()
            client.setup(unleashUrl: url, clientKey: key, context: [:])

            XCTAssertNil(client.client, "expected no client for url \(url.debugDescription) key \(key.debugDescription)")
            XCTAssertNil(client.headerValue)
            XCTAssertFalse(client.has("shorts"))
            XCTAssertNil(client.variant("shorts"))
        }
    }

    /// `ContentView.load()` runs on launch, on every foreground and on auth changes. Each `setup`
    /// used to build a new client and orphan the previous one's poll and metrics timers.
    func testRepeatedSetupWithSameContextReusesOneClient() {
        let client = FeatureFlagsClient()
        let context = ["os": "tvos", "userId": "123"]

        client.setup(unleashUrl: "https://unleash.invalid", clientKey: "abc", context: context)
        let first = client.client
        XCTAssertNotNil(first)

        client.setup(unleashUrl: "https://unleash.invalid", clientKey: "abc", context: context)
        XCTAssertTrue(first === client.client, "setup should reuse the existing client")

        client.setup(unleashUrl: "https://unleash.invalid", clientKey: "abc", context: ["os": "tvos"])
        XCTAssertTrue(first === client.client, "a context change should update the client, not replace it")
    }
}
