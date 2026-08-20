// swift-tools-version: 6.4

import PackageDescription

extension String {
    static let rfc1123: Self = "RFC 1123"
}

extension Target.Dependency {
    static var rfc1123: Self { .target(name: .rfc1123) }
    static var rfc1035: Self { .product(name: "RFC 1035", package: "swift-rfc-1035") }
    static var standards: Self {
        .product(name: "Standard Library Extensions", package: "swift-standard-library-extensions")
    }
    static var incits41986: Self {
        .product(name: "ASCII Serializer Primitives", package: "swift-ascii-serializer-primitives")
    }
    static var asciiParser: Self {
        .product(name: "Parseable ASCII Primitives", package: "swift-ascii-parser-primitives")
    }
}

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
            url: "https://github.com/swift-primitives/swift-standard-library-extensions.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-ascii-serializer-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-ascii-parser-primitives.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "RFC 1123",
            dependencies: [
                .rfc1035,
                .standards,
                .incits41986,
                .asciiParser,
            ]
        ),
        .testTarget(
            name: "RFC 1123 Tests",
            dependencies: [
                "RFC 1123"
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

extension String { var tests: Self { self + " Tests" } }

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
