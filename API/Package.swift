// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "API",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_14),
        .tvOS(.v13),
        .watchOS(.v5),
    ],
    products: [
        .library(name: "API", targets: ["API"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apollographql/apollo-ios.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "API",
            dependencies: [
                .product(name: "ApolloAPI", package: "apollo-ios"),
            ],
            path: "./Sources"
        ),
    ]
)
