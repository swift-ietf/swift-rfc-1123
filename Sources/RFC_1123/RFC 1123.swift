//
//  File.swift
//  swift-web
//
//  Created by Coen ten Thije Boonkkamp on 28/12/2024.
//

import RFC_1035

/// RFC 1123 compliant host name
public struct Domain: Hashable, Sendable {
    /// The labels that make up the host name, from least significant to most significant
    private let labels: [Label]

    /// Initialize with an array of string labels, validating RFC 1123 rules
    public init(labels: [String]) throws {
        guard !labels.isEmpty else {
            throw ValidationError.empty
        }

        guard labels.count <= Limits.maxLabels else {
            throw ValidationError.tooManyLabels
        }

        // Validate TLD according to stricter RFC 1123 rules
        guard let tld = labels.last else {
            throw ValidationError.empty
        }

        // Convert and validate labels
        var validatedLabels = try labels.dropLast().map { label in
            try Label(label, validateAs: .label)
        }

        // Add TLD with stricter validation
        validatedLabels.append(try Label(tld, validateAs: .tld))

        self.labels = validatedLabels

        // Check total length including dots
        let totalLength = self.name.count
        guard totalLength <= Limits.maxLength else {
            throw ValidationError.tooLong(totalLength)
        }
    }

    /// Initialize from a string representation (e.g. "host.example.com")
    public init(_ string: String) throws {
        try self.init(
            labels: string.split(separator: ".", omittingEmptySubsequences: true).map(String.init)
        )
    }
}

// MARK: - Label Validation Type
extension Domain {
    enum ValidationType {
        case label  // Regular label rules
        case tld  // Stricter TLD rules
    }
}

// MARK: - Label Type
extension Domain {
    /// A type-safe host label that enforces RFC 1123 rules
    public struct Label: Hashable, Sendable {
        public let value: String

        /// Initialize a label, validating RFC 1123 rules
        internal init(_ string: String, validateAs type: ValidationType) throws {
            guard !string.isEmpty, string.count <= Domain.Limits.maxLabelLength else {
                throw type == .tld
                    ? Domain.ValidationError.invalidTLD(string)
                    : Domain.ValidationError.invalidLabel(string)
            }

            let regex = type == .tld ? Domain.tldRegex : Domain.labelRegex
            guard (try? regex.wholeMatch(in: string)) != nil else {
                throw type == .tld
                    ? Domain.ValidationError.invalidTLD(string)
                    : Domain.ValidationError.invalidLabel(string)
            }

            self.value = string
        }
    }
}

// MARK: - Constants and Validation
extension Domain {
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
extension Domain {
    /// The complete host name as a string
    public var name: String {
        labels.map(String.init).joined(separator: ".")
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
    public func isSubdomain(of parent: Domain) -> Bool {
        guard labels.count > parent.labels.count else { return false }
        return labels.suffix(parent.labels.count) == parent.labels
    }

    /// Creates a subdomain by prepending new labels
    public func addingSubdomain(_ components: [String]) throws -> Domain {
        try Domain(labels: components + labels.map(String.init))
    }

    public func addingSubdomain(_ components: String...) throws -> Domain {
        try self.addingSubdomain(components)
    }

    /// Returns the parent domain by removing the leftmost label
    public func parent() throws -> Domain? {
        guard labels.count > 1 else { return nil }
        return try Domain(labels: labels.dropFirst().map(String.init))
    }

    /// Returns the root domain (tld + sld)
    public func root() throws -> Domain? {
        guard labels.count >= 2 else { return nil }
        return try Domain(labels: labels.suffix(2).map(String.init))
    }
}

// MARK: - Errors
extension Domain {
    public enum ValidationError: Error, Equatable {
        case empty
        case tooLong(_ length: Int)
        case tooManyLabels
        case invalidLabel(_ label: String)
        case invalidTLD(_ tld: String)
    }
}

// MARK: - Convenience Initializers
extension Domain {
    /// Creates a host from root level components
    public static func root(_ sld: String, _ tld: String) throws -> Domain {
        try Domain(labels: [sld, tld])
    }

    /// Creates a subdomain with components in most-to-least significant order
    public static func subdomain(_ components: String...) throws -> Domain {
        try Domain(labels: components.reversed())
    }
}

// MARK: - Protocol Conformances
extension Domain: CustomStringConvertible {
    public var description: String { name }
}

extension Domain: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(name)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        try self.init(string)
    }
}

extension Domain: RawRepresentable {
    public var rawValue: String { name }
    public init?(rawValue: String) { try? self.init(rawValue) }
}

extension RFC_1123.Domain {
    public init(_ domain: RFC_1035.Domain) throws {
        try self.init(domain.name)
    }
}

extension RFC_1035.Domain {
    public init(_ domain: RFC_1123.Domain) throws {
        try self.init(domain.name)
    }
}
