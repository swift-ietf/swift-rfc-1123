//
//  File.swift
//  swift-rfc-1123
//
//  Created by Coen ten Thije Boonkkamp on 21/11/2025.
//

import INCITS_4_1986
import Standards
public import RFC_1035

extension RFC_1123 {
    /// RFC 1123 compliant host name
    public struct Domain: Hashable, Sendable {
        /// The labels that make up the host name, from least significant to most significant
        let labels: [Label]

        /// Initialize with an array of validated labels, performing domain-level validation
        ///
        /// This is the canonical initializer. Labels are already validated,
        /// so this only performs compositional validation (count, total length).
        public init(labels: [Label]) throws(Error) {
            guard !labels.isEmpty else {
                throw Error.empty
            }

            guard labels.count <= Limits.maxLabels else {
                throw Error.tooManyLabels
            }

            self.labels = labels

            // Check total length including dots
            let totalLength = self.name.count
            guard totalLength <= Limits.maxLength else {
                throw Error.tooLong(totalLength)
            }
        }
    }
}

// MARK: - Convenience Initializers
extension RFC_1123.Domain {
    /// Initialize with an array of string labels, validating and converting to Labels
    ///
    /// Convenience initializer that validates strings as labels (with TLD-specific validation),
    /// then delegates to the canonical `init(labels: [Label])`.
    public init(labels labelStrings: some Sequence<some StringProtocol>) throws(Error) {
        guard !labelStrings.isEmpty else {
            throw Error.empty
        }

        // Validate TLD according to stricter RFC 1123 rules
        guard let tld = labelStrings.last else {
            throw Error.empty
        }

        // Convert and validate labels, wrapping Label.Error
        var validatedLabels: [Label] = []
        validatedLabels.reserveCapacity(labelStrings.count)

        for labelString in labelStrings.dropLast() {
            do {
                validatedLabels.append(try Label(labelString, validateAs: .label))
            } catch {
                // Typed throws: compiler knows error is Label.Error
                throw Error.invalidLabel(error)
            }
        }

        // Add TLD with stricter validation
        do {
            validatedLabels.append(try Label(tld, validateAs: .tld))
        } catch {
            // Typed throws: compiler knows error is Label.Error
            throw Error.invalidLabel(error)
        }

        // Delegate to canonical initializer
        try self.init(labels: validatedLabels)
    }

    /// Initialize from a string representation (e.g. "host.example.com")
    ///
    /// Convenience initializer that parses dot-separated labels.
    public init(_ string: some StringProtocol) throws(Error) {
        try self.init(
            labels: string
                .split(separator: ".", omittingEmptySubsequences: true)
                .map(String.init)
        )
    }

    /// Initialize from bytes representation
    ///
    /// Convenience initializer that decodes bytes as UTF-8 and validates.
    public init(_ bytes: [UInt8]) throws(Error) {
        // Decode bytes as UTF-8 and validate
        let string = String(decoding: bytes, as: UTF8.self)
        try self.init(string)
    }
}

// MARK: - Label Validation Type
extension RFC_1123.Domain {
    enum ValidationType {
        case label  // Regular label rules
        case tld  // Stricter TLD rules
    }
}

// MARK: - Label Type
extension RFC_1123.Domain {
    /// A type-safe host label that enforces RFC 1123 rules
    public struct Label: Hashable, Sendable {
        /// Canonical byte storage (ASCII-only per RFC 1123)
        let _value: [UInt8]

        /// String representation derived from canonical bytes via String extension init
        public var value: String {
            String(self)
        }

        /// Initialize a label from a string, validating RFC 1123 rules
        internal init(_ string: some StringProtocol, validateAs type: ValidationType) throws(Error) {
            // Check emptiness
            guard !string.isEmpty else {
                throw Error.empty
            }

            // Check length
            guard string.count <= RFC_1123.Domain.Limits.maxLabelLength else {
                throw Error.tooLong(string.count, label: string)
            }

            // Validate against appropriate regex
            let regex = type == .tld ? RFC_1123.Domain.tldRegex : RFC_1123.Domain.labelRegex
            guard (try? regex.wholeMatch(in: string)) != nil else {
                throw type == .tld
                    ? Error.invalidTLD(string)
                    : Error.invalidCharacters(string)
            }

            // Store as canonical byte representation (ASCII-only)
            self._value = [UInt8](utf8: string)
        }

        /// Initialize a label from bytes, validating RFC 1123 rules
        internal init(_ bytes: [UInt8], validateAs type: ValidationType) throws(Error) {
            // Decode bytes as UTF-8 and validate
            let string = String(decoding: bytes, as: UTF8.self)
            try self.init(string, validateAs: type)
        }
    }
}

// MARK: - Constants and Validation
extension RFC_1123.Domain {
    internal enum Limits {
        static let maxLength = 255
        static let maxLabels = 127
        static let maxLabelLength = 63
    }

    /// RFC 1123 label regex:
    /// - Can begin with letter or digit
    /// - Can end with letter or digit
    /// - May have hyphens in interior positions only
    nonisolated(unsafe) internal static let labelRegex = /[a-zA-Z0-9](?:[a-zA-Z0-9\-]*[a-zA-Z0-9])?/

    /// RFC 1123 TLD regex:
    /// - Must begin with a letter
    /// - Must end with a letter
    /// - May have hyphens in interior positions only
    nonisolated(unsafe) internal static let tldRegex = /[a-zA-Z](?:[a-zA-Z0-9\-]*[a-zA-Z])?/
}

// MARK: - Properties and Methods
extension RFC_1123.Domain {
    /// The complete host name as a string
    public var name: String {
        labels.map(\.description).joined(separator: ".")
    }

    /// The top-level domain (rightmost label)
    public var tld: Label? {
        labels.last
    }

    /// The second-level domain (second from right)
    public var sld: Label? {
        labels.dropLast().last
    }

    /// Returns true if this is a subdomain of the given host
    public func isSubdomain(of parent: RFC_1123.Domain) -> Bool {
        guard labels.count > parent.labels.count else { return false }
        return labels.suffix(parent.labels.count) == parent.labels
    }

    /// Creates a subdomain by prepending new labels
    public func addingSubdomain(_ components: [String]) throws(Error) -> RFC_1123.Domain {
        // Uses string convenience init since mixing strings with existing labels
        try RFC_1123.Domain(labels: components + labels.map(String.init))
    }

    public func addingSubdomain(_ components: String...) throws(Error) -> RFC_1123.Domain {
        try self.addingSubdomain(components)
    }

    /// Returns the parent domain by removing the leftmost label
    public func parent() throws(Error) -> RFC_1123.Domain? {
        guard labels.count > 1 else { return nil }
        // Use canonical init with validated Labels
        return try RFC_1123.Domain(labels: Array(labels.dropFirst()))
    }

    /// Returns the root domain (tld + sld)
    public func root() throws(Error) -> RFC_1123.Domain? {
        guard labels.count >= 2 else { return nil }
        // Use canonical init with validated Labels
        return try RFC_1123.Domain(labels: Array(labels.suffix(2)))
    }
}


// MARK: - Convenience Initializers
extension RFC_1123.Domain {
    /// Creates a host from root level components
    public static func root(_ sld: String, _ tld: String) throws(Error) -> RFC_1123.Domain {
        try RFC_1123.Domain(labels: [sld, tld])
    }

    /// Creates a subdomain with components in most-to-least significant order
    public static func subdomain(_ components: String...) throws(Error) -> RFC_1123.Domain {
        try RFC_1123.Domain(labels: components.reversed())
    }
}

// MARK: - Protocol Conformances
extension RFC_1123.Domain: CustomStringConvertible {
    public var description: String { name }
}

extension RFC_1123.Domain: Codable {
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(name)
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        try self.init(string)
    }
}

extension RFC_1123.Domain: RawRepresentable {
    public var rawValue: String { name }
    public init?(rawValue: String) { try? self.init(rawValue) }
}

extension RFC_1123.Domain {
    public init(_ domain: RFC_1035.Domain) throws(Error) {
        try self.init(domain.name)
    }
}

extension RFC_1123.Domain.Label: CustomStringConvertible {
    public var description: String { String(self) }
}
