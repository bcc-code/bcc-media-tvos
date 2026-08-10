// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Authentication",
    platforms: [
        .tvOS(.v16),
        // The app only ships for tvOS, but without a macOS floor the host build resolves to the
        // default 10.13 and fails against Auth0's macOS 11 requirement — which meant `swift build`
        // and `swift test` could not run here at all, so this package's tests never executed.
        // 12 rather than 11 because the source uses `Date.now`. Host-only; nothing ships for macOS.
        .macOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Authentication",
            targets: ["Authentication"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/auth0/Auth0.swift", from: "2.5.0"),
        .package(url: "https://github.com/getsentry/sentry-cocoa", from: "8.34.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Authentication",
            dependencies: [
                .product(name: "Auth0", package: "auth0.swift"),
                .product(name: "Sentry", package: "sentry-cocoa")
            ]
        ),
        .testTarget(
            // Prefixed like FeatureFlagsTests and APITests: target names have to be unique across the
            // whole package graph, so a plain "UnitTests" here collides with any sibling that wants it.
            name: "AuthenticationTests",
            dependencies: [
                "Authentication",
                // The reauthentication tests construct Auth0's own error types.
                .product(name: "Auth0", package: "auth0.swift")
            ],
            // Explicit because the sources sit directly in Tests/, not Tests/AuthenticationTests/.
            path: "Tests"
        )
    ]
)
