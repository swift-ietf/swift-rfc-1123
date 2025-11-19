// swift-tools-version:6.0

import PackageDescription

extension String {
    static let rfc1123: Self = "RFC_1123"
}

extension Target.Dependency {
    static var rfc1123: Self { .target(name: .rfc1123) }
    static var rfc1035: Self { .product(name: "RFC_1035", package: "swift-rfc-1035") }
}

let package = Package(
    name: "swift-rfc-1123",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .tvOS(.v18),
        .watchOS(.v11)
    ],
    products: [
        .library(name: .rfc1123, targets: [.rfc1123]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-standards/swift-rfc-1035.git", from: "0.0.1"),
    ],
    targets: [
        .target(
            name: .rfc1123,
            dependencies: [
                .rfc1035
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
