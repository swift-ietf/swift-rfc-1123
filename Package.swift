// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-rfc-1123",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(name: "RFC 1123", targets: ["RFC 1123"])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-ietf/swift-rfc-1035.git", branch: "main"),
        .package(
            url: "https://github.com/swift-atoms/swift-standard-library-extensions.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-ascii-serializer.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-ascii-parser.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-byte.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "RFC 1123",
            dependencies: [
                .product(name: "RFC 1035", package: "swift-rfc-1035"),
                .product(name: "Standard Library Extensions", package: "swift-standard-library-extensions"),
                .product(name: "ASCII Serializer", package: "swift-ascii-serializer"),
                .product(name: "Parseable ASCII", package: "swift-ascii-parser"),
                .product(name: "Byte", package: "swift-byte"),
                .product(name: "Byte Standard Library Integration", package: "swift-byte"),
            ]
        ),
        .testTarget(
            name: "RFC 1123 Tests",
            dependencies: [
                .target(name: "RFC 1123"),
                .product(name: "Byte", package: "swift-byte"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
