// swift-tools-version:5.7

import PackageDescription

let package = Package(
  name: "API",
  platforms: [
    .iOS(.v16),
    // The app only ships for tvOS, but 10.14 is below the 10.15 that Swift concurrency needs, so
    // `swift build` and `swift test` could not run here at all and this package had no tests.
    // 12 to match Authentication. Host-only; nothing ships for macOS.
    .macOS(.v12),
    .tvOS(.v16),
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
        .product(name: "Apollo", package: "apollo-ios"),
        .product(name: "ApolloAPI", package: "apollo-ios"),
      ],
      path: "./Sources"
    ),
    .testTarget(
      // Prefixed like FeatureFlagsTests and AuthenticationTests: target names have to be unique
      // across the whole package graph.
      name: "APITests",
      dependencies: [
        "API",
        // The stub network transport implements Apollo's own NetworkTransport and parses canned
        // response bodies with GraphQLResponse. The generated sources re-export ApolloAPI but not
        // Apollo, so this has to be spelled out.
        .product(name: "Apollo", package: "apollo-ios"),
      ],
      // Explicit because the library target also opts out of the default SPM layout.
      path: "./Tests"
    ),
  ]
)
