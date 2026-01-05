// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ARCNetworking",

    // MARK: - Platforms

    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17),
        .watchOS(.v10)
    ],

    // MARK: - Products

    products: [
        .library(
            name: "ARCNetworking",
            targets: ["ARCNetworking"]
        )
    ],

    // MARK: - Targets

    targets: [
        .target(
            name: "ARCNetworking",
            path: "Sources/ARCNetworking",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "ARCNetworkingTests",
            dependencies: ["ARCNetworking"],
            path: "Tests/ARCNetworkingTests"
        )
    ],

    // MARK: - Swift Language

    swiftLanguageModes: [.v6]
)
