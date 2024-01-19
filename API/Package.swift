// swift-tools-version:5.7

import PackageDescription

let package = Package(
  name: "API",
  platforms: [
    .tvOS(.v16),
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
      ],
      path: "./Sources",
      swiftSettings: [
        .define("COCOAPODS")]
    ),
  ]
)
