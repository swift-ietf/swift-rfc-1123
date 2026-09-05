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
        .library(
            name: "RFC 1123",
            targets: ["RFC 1123"]
        ),
        .library(
            name: "RFC 1123 Foundation Integration",
            targets: ["RFC 1123 Foundation Integration"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-ietf/swift-rfc-1035.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-ascii.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-byte.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "RFC 1123",
            dependencies: [
                .product(name: "RFC 1035", package: "swift-rfc-1035"),
                .product(name: "ASCII", package: "swift-ascii"),
                .product(name: "Byte", package: "swift-byte"),
                .product(name: "Byte Standard Library Integration", package: "swift-byte"),
            ]
        ),
        .target(
            name: "RFC 1123 Foundation Integration",
            dependencies: [
                .target(name: "RFC 1123")
            ]
        ),
        .testTarget(
            name: "RFC 1123 Foundation Integration Tests",
            dependencies: [
                .target(name: "RFC 1123"),
                .target(name: "RFC 1123 Foundation Integration"),
            ]
        ),
        .testTarget(
            name: "RFC 1123 Tests",
            dependencies: [
                .target(name: "RFC 1123"),
                .product(name: "RFC 1035", package: "swift-rfc-1035"),
                .product(name: "Byte", package: "swift-byte"),
                .product(name: "Byte Standard Library Integration", package: "swift-byte"),
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
