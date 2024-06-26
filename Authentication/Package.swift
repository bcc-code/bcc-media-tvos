// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Authentication",
    platforms: [
        .tvOS(.v16)
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
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.26.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Authentication",
            dependencies: [
                .product(name: "Auth0", package: "auth0.swift"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk")
            ]
        )
    ]
)
