// The Swift Programming Language
// https://docs.swift.org/swift-book

import UnleashProxyClientSwift

private var client: UnleashProxyClientSwift.UnleashClient?

private func handleReady() {
    loaded = true
    onLoadCallback()
}

public func setup(unleashUrl: String, clientKey: String, context: [String: String]) {
    client = UnleashProxyClientSwift.UnleashClient(unleashUrl: unleashUrl, clientKey: clientKey, refreshInterval: 60, appName: "bccm-tvos", context: context)
    client!.start { err in
        if err != nil {
            print(err as Any)
        }
        handleReady()
    }

    client!.subscribe(name: "update") {
        onUpdateCallback()
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

private var onLoadCallback: () -> Void = {}

public func onLoad(callback: @escaping () -> Void) {
    onLoadCallback = callback
}

private var onUpdateCallback: () -> Void = {}

public func onUpdate(callback: @escaping () -> Void) {
    onUpdateCallback = callback
}
