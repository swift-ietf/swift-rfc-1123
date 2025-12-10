// swift-tools-version: 6.2

import PackageDescription

extension String {
    static let rfc1123: Self = "RFC 1123"
}

extension Target.Dependency {
    static var rfc1123: Self { .target(name: .rfc1123) }
    static var rfc1035: Self { .product(name: "RFC 1035", package: "swift-rfc-1035") }
    static var standards: Self { .product(name: "Standards", package: "swift-standards") }
    static var incits41986: Self { .product(name: "INCITS 4 1986", package: "swift-incits-4-1986") }
}

let package = Package(
    name: "swift-rfc-1123",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(name: .rfc1123, targets: [.rfc1123])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-standards/swift-rfc-1035", from: "0.4.2"),
        .package(url: "https://github.com/swift-standards/swift-standards", from: "0.10.0"),
        .package(url: "https://github.com/swift-standards/swift-incits-4-1986", from: "0.6.2"),
    ],
    targets: [
        .target(
            name: .rfc1123,
            dependencies: [
                .rfc1035,
                .standards,
                .incits41986,
            ]
        ),
        .testTarget(
            name: .rfc1123.tests,
            dependencies: [
                .rfc1123
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

extension String { var tests: Self { self + " Tests" } }
