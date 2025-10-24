// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ARCNetworking",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .tvOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "ARCNetworking",
            targets: ["ARCNetworking"]
        ),
    ],
    targets: [
        .target(
            name: "ARCNetworking",
            path: "Sources"
        ),
        .testTarget(
            name: "ARCNetworkingTests",
            dependencies: ["ARCNetworking"],
            path: "Tests"
        )
    ]
)
