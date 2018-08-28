// swift-tools-version:4.1

import PackageDescription

let package = Package(
    name: "SwiftHelpers",
    products: [
        .library(
            name: "SwiftHelpers",
            targets: ["SwiftHelpers"]),
    ],
    dependencies: [
        .package(url: "https://github.com/sharplet/Regex.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "2.4.4"),
        .package(url: "https://github.com/vapor/leaf-provider.git", from: "1.1.0")
    ],
    targets: [
        .target(
            name: "SwiftHelpers", dependencies: ["Vapor", "Regex", "LeafProvider"]),
        .testTarget(
            name: "SwiftHelpersTests",
            dependencies: ["SwiftHelpers"]),
    ]
)
