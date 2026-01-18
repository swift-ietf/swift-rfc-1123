// swift-tools-version: 6.2

import PackageDescription

extension String {
    static let rfc1123: Self = "RFC 1123"
}

extension Target.Dependency {
    static var rfc1123: Self { .target(name: .rfc1123) }
    static var rfc1035: Self { .product(name: "RFC 1035", package: "swift-rfc-1035") }
    static var standards: Self { .product(name: "Standard Library Extensions", package: "swift-standard-library-extensions") }
    static var incits41986: Self { .product(name: "ASCII", package: "swift-ascii") }
}

let package = Package(
    name: "swift-rfc-1123",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        .library(name: "RFC 1123", targets: ["RFC 1123"])
    ],
    dependencies: [
        .package(path: "../swift-rfc-1035"),
        .package(path: "../../swift-primitives/swift-standard-library-extensions"),
        .package(path: "../../swift-foundations/swift-ascii")
    ],
    targets: [
        .target(
            name: "RFC 1123",
            dependencies: [
                .rfc1035,
                .standards,
                .incits41986
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)

extension String { var tests: Self { self + " Tests" } }
