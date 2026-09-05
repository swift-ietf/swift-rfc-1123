# Swift RFC 1123

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)
[![CI](https://github.com/swift-ietf/swift-rfc-1123/workflows/CI/badge.svg)](https://github.com/swift-ietf/swift-rfc-1123/actions/workflows/ci.yml)

Swift implementation of RFC 1123: Requirements for Internet Hosts - Application and Support.

## Overview

RFC 1123 updates RFC 1035 with relaxed domain name syntax rules for modern internet hosts. This package provides a pure Swift implementation of RFC 1123-compliant hostnames with full validation, type-safe label handling, and convenient APIs for working with host hierarchies.

The package enforces RFC 1123 rules which allow labels to begin with digits (unlike RFC 1035), while requiring that the TLD starts with a letter (to distinguish hostnames from IP addresses). It provides seamless conversion between RFC 1035 and RFC 1123 domain representations.

## Features

- **RFC 1123 Compliance**: Full validation of hostname syntax according to RFC 1123 specification
- **Relaxed Label Rules**: Labels can begin with digits (e.g., "123.example.com" is valid)
- **TLD Validation**: Top-level domains must start with a letter (per RFC 1123 Section 2.1)
- **RFC 1035 Interoperability**: Seamless conversion between RFC 1035 and RFC 1123 domains
- **Type-Safe Labels**: Label type that enforces RFC 1123 rules at compile time
- **Domain Hierarchy**: Navigate parent domains, root domains, and detect subdomain relationships
- **Foundation Integration**: `Codable` conformances in the `RFC 1123 Foundation Integration` product
- **Wire Coding**: byte-level parsing and serialization live in the sibling package [swift-rfc-1123-coder](https://github.com/swift-ietf/swift-rfc-1123-coder)

## Installation

Add swift-rfc-1123 to your package dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/swift-ietf/swift-rfc-1123.git", branch: "main")
]
```

Then add it to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "RFC 1123", package: "swift-rfc-1123")
    ]
)
```

## Quick Start

### Creating Hostnames

```swift
import RFC_1123

// Create from string
let host = try Domain("example.com")

// RFC 1123 allows labels starting with digits
let numericHost = try Domain("123.example.com")

// Create from root components
let host = try Domain.root("example", "com")

// Create subdomain with reversed components
let host = try Domain.subdomain("com", "example", "api")
// Result: "api.example.com"
```

### Working with Domain Components

```swift
let host = try Domain("api.example.com")

// Access TLD and SLD
print(host.tld?.rawValue)  // "com"
print(host.sld?.rawValue)  // "example"

// Get full hostname
print(host.name)  // "api.example.com"
```

### Domain Hierarchy Navigation

```swift
let host = try Domain("api.v1.example.com")

// Get parent domain
let parent = host.parent()
print(parent?.name)  // "v1.example.com"

// Get root domain (TLD + SLD)
let root = host.root()
print(root?.name)  // "example.com"

// Add subdomain
let subdomain = try host.addingSubdomain("staging")
print(subdomain.name)  // "staging.api.v1.example.com"

// Check subdomain relationships
let parent = try Domain("example.com")
let child = try Domain("api.example.com")
print(child.isSubdomain(of: parent))  // true
```

### RFC 1035 Interoperability

```swift
import RFC_1035
import RFC_1123

// Convert RFC 1035 domain to RFC 1123
let rfc1035Domain = try RFC_1035.Domain("example.com")
let rfc1123Domain = try RFC_1123.Domain(rfc1035Domain)

// Convert RFC 1123 domain to RFC 1035
let backToRFC1035 = try RFC_1035.Domain(rfc1123Domain)
```

## Usage

### Domain Type

The core `Domain` type is a struct that validates and stores hostnames:

```swift
public struct Domain: Hashable, Sendable {
    public init(_ string: some StringProtocol) throws(Error)
    public init(ascii bytes: some Collection<Byte>) throws(Error)
    public init(labels: [Domain.Label]) throws(Error)

    public var name: String
    public var tld: Domain.Label?
    public var sld: Domain.Label?

    public func isSubdomain(of parent: Domain) -> Bool
    public func addingSubdomain(_ components: [String]) throws(Error) -> Domain
    public func addingSubdomain(_ components: String...) throws(Error) -> Domain
    public func parent() -> Domain?
    public func root() -> Domain?
}
```

### Validation Rules

RFC 1123 enforces the following rules:

- **Label Length**: Each label must be 1-63 characters
- **Total Length**: Complete hostname must not exceed 255 characters
- **Label Count**: Maximum 127 labels
- **Regular Label Format**:
  - Can start with letter or digit (a-z, A-Z, 0-9)
  - Can end with letter or digit
  - May contain letters, digits, and hyphens in interior positions
- **TLD Format**:
  - Must start with a letter (a-z, A-Z) per RFC 1123 Section 2.1
  - Can end with letter or digit
  - May contain letters, digits, and hyphens in interior positions

### Key Differences from RFC 1035

| Rule | RFC 1035 | RFC 1123 |
|------|----------|----------|
| Label can start with digit | No | Yes |
| TLD can start with digit | No | No |
| TLD can end with digit | Yes | Yes |

### Error Handling

```swift
do {
    let host = try Domain("example.com")
} catch Domain.Error.empty {
    print("Host cannot be empty")
} catch Domain.Error.tooLong(let length) {
    print("Host length \(length) exceeds maximum")
} catch Domain.Error.tooManyLabels {
    print("Too many labels in host")
} catch Domain.Error.invalidLabel(let label) {
    print("Invalid label: \(label)")
} catch Domain.Error.invalidTLD(let tld) {
    print("Invalid TLD: \(tld)")
}
```

### Codable Support

Add the `RFC 1123 Foundation Integration` product and import `RFC_1123_Foundation_Integration`:

```swift
let host = try Domain("example.com")

// Encode to JSON
let encoded = try JSONEncoder().encode(host)

// Decode from JSON
let decoded = try JSONDecoder().decode(Domain.self, from: encoded)
```

## Related Packages

### Dependencies
- [swift-rfc-1035](https://github.com/swift-ietf/swift-rfc-1035) - RFC 1035 domain names (stricter predecessor)

### Siblings
- [swift-rfc-1123-coder](https://github.com/swift-ietf/swift-rfc-1123-coder) - `RFC_1123.Domain.Coder` and `RFC_1123.Domain.Label.Coder`, ASCII/Binary serialization

## Requirements

- Swift 6.4+
- macOS 27+ / iOS 27+

## License

This library is released under the Apache License 2.0. See [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
