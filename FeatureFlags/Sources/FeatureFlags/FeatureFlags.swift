// The Swift Programming Language
// https://docs.swift.org/swift-book

import UnleashProxyClientSwift

private var client: UnleashProxyClientSwift.UnleashClient? = nil

public func setup(unleashUrl: String, clientKey: String, anonymousId: String) {
    client = UnleashProxyClientSwift.UnleashClient(unleashUrl: unleashUrl, clientKey: clientKey, context: ["userId": anonymousId])
    client!.subscribe(name: "ready") {
        loaded = true
    }
}

public func has(_ key: String) -> Bool {
    client?.isEnabled(name: key) == true
}

public func variant(_ key: String) -> String? {
    let variant = client?.getVariant(name: key)
    if variant?.enabled == true {
        return variant?.payload?.value
    }
    return nil
}

public var loaded = false
