// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FeatureFlags",
    platforms: [
        .tvOS(.v16),
        // Not shipped anywhere; lets `swift test` run the suite on the host.
        .macOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "FeatureFlags",
            targets: ["FeatureFlags"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Unleash/unleash-proxy-client-swift", from: "2.5.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "FeatureFlags",
            dependencies: [
                .product(name: "UnleashProxyClientSwift", package: "unleash-proxy-client-swift")
            ]
        ),
        .testTarget(
            name: "FeatureFlagsTests",
            dependencies: ["FeatureFlags"]
        ),
    ]
)
