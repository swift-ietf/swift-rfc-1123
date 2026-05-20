//
//  RFC_1123.Domain.swift
//  swift-rfc-1123
//
//  Created by Coen ten Thije Boonkkamp on 21/11/2025.
//

public import ASCII_Serializer_Primitives
import RFC_1035

extension RFC_1123 {
    /// RFC 1123 compliant host name
    ///
    /// Represents a fully qualified host name as defined by RFC 1123 Section 2.1.
    /// RFC 1123 relaxes RFC 1035's constraint that labels must start with a letter,
    /// allowing labels to begin with digits.
    ///
    /// ## RFC 1123 vs RFC 1035
    ///
    /// RFC 1123 Section 2.1 states:
    /// > The syntax of a legal Internet host name was specified in RFC-952.
    /// > One aspect of host name syntax is hereby changed: the restriction on
    /// > the first character is relaxed to allow either a letter or a digit.
    ///
    /// However, it also states:
    /// > a valid host name can never have the dotted-decimal form #.#.#.#, since
    /// > at least the highest-level component label will be alphabetic.
    ///
    /// Key differences from RFC 1035:
    /// - Labels CAN start with digits (e.g., "3com" is valid)
    /// - The highest-level label (TLD) MUST start with a letter
    /// - All other RFC 1035 rules apply (max 63 chars per label, etc.)
    ///
    /// ## Example
    ///
    /// ```swift
    /// let host = try RFC_1123.Domain("www.3com.com")  // Valid
    /// print(host.tld) // "com"
    /// print(host.sld) // "3com"
    /// ```
    ///
    /// ## RFC Reference
    ///
    /// From RFC 1123 Section 2.1:
    ///
    /// > Host software MUST handle host names of up to 63 characters and
    /// > SHOULD handle host names of up to 255 characters.
    public struct Domain: Sendable, Codable {
        /// The domain name as a string
        public let rawValue: String

        /// The labels that make up the host name, from least significant to most significant
        package let labels: [Domain.Label]

        /// Creates a domain WITHOUT validation
        ///
        /// **Warning**: Bypasses RFC 1123 validation.
        /// Only use with compile-time constants or pre-validated values.
        ///
        /// - Parameters:
        ///   - unchecked: Void parameter to prevent accidental use
        ///   - rawValue: The raw domain name (unchecked)
        ///   - labels: Pre-validated labels
        init(
            __unchecked: Void,
            rawValue: String,
            labels: [Domain.Label]
        ) {
            self.rawValue = rawValue
            self.labels = labels
        }
    }
}

extension RFC_1123.Domain: Hashable {
    /// Hash value (case-insensitive per RFC 1123)
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue.lowercased())
    }

    /// Equality comparison (case-insensitive per RFC 1123)
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue.lowercased() == rhs.rawValue.lowercased()
    }

    /// Equality comparison with raw value (case-insensitive)
    public static func == (lhs: Self, rhs: Self.RawValue) -> Bool {
        lhs.rawValue.lowercased() == rhs.lowercased()
    }
}

extension RFC_1123.Domain: Binary.ASCII.RawRepresentable {}

extension RFC_1123.Domain: CustomStringConvertible {}

extension RFC_1123.Domain: Binary.ASCII.Serializable {
    public static func serialize<Buffer: RangeReplaceableCollection>(
        ascii domain: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        buffer.append(contentsOf: Array<Byte>(domain.rawValue.utf8))
    }

    /// Parses a host name from canonical byte representation (CANONICAL PRIMITIVE)
    ///
    /// This is the primitive parser that works at the byte level.
    /// RFC 1123 host names are ASCII-only, dot-separated labels.
    ///
    /// ## RFC 1123 Compliance
    ///
    /// Per RFC 1123 Section 2.1:
    /// - Maximum 255 octets total
    /// - Maximum 127 labels
    /// - Labels separated by dots (0x2E)
    /// - Labels can start with letters or digits
    /// - The highest-level component label (TLD) must start with a letter
    ///
    /// ## Category Theory
    ///
    /// This is the fundamental parsing transformation:
    /// - **Domain**: [UInt8] (ASCII bytes)
    /// - **Codomain**: RFC_1123.Domain (structured data)
    ///
    /// String-based parsing is derived as composition:
    /// ```
    /// String → [UInt8] (UTF-8 bytes) → Domain
    /// ```
    ///
    /// ## Example
    ///
    /// ```swift
    /// let bytes = Array("www.3com.com".utf8)
    /// let domain = try RFC_1123.Domain(ascii: bytes)
    /// ```
    ///
    /// - Parameter bytes: The ASCII byte representation of the domain
    /// - Throws: `RFC_1123.Domain.Error` if the bytes are malformed
    public init<Bytes: Collection>(ascii bytes: Bytes, in context: Void) throws(Error)
    where Bytes.Element == Byte {
        guard !bytes.isEmpty else {
            throw Error.empty
        }

        let length = bytes.count
        guard length <= Limits.maxLength else {
            throw Error.tooLong(length)
        }

        var labelSlices: [Bytes.SubSequence] = []
        var currentStart = bytes.startIndex
        var i = currentStart

        while i != bytes.endIndex {
            let code = ASCII.Code(bytes[i])
            if code == ASCII.Code.period {
                let segment = bytes[currentStart..<i]
                if !segment.isEmpty {
                    labelSlices.append(segment)
                }
                currentStart = bytes.index(after: i)
            }
            i = bytes.index(after: i)
        }

        if currentStart != bytes.endIndex {
            labelSlices.append(bytes[currentStart..<bytes.endIndex])
        }

        guard !labelSlices.isEmpty else {
            throw Error.empty
        }

        guard labelSlices.count <= Limits.maxLabels else {
            throw Error.tooManyLabels
        }

        var labels: [Label] = []
        labels.reserveCapacity(labelSlices.count)

        for slice in labelSlices {
            do {
                labels.append(try Label(ascii: slice))
            } catch {
                throw Error.invalidLabel(error)
            }
        }

        // RFC 1123 Section 2.1:
        // "the highest-level component label will be alphabetic"
        if let tld = labels.last {
            guard tld.rawValue.utf8.allSatisfy({ ASCII.Code(Byte($0)).isLetter }) else {
                throw Error.invalidTLD(tld.rawValue)
            }
        }

        let rawValue = String(decoding: bytes, as: UTF8.self)
        self.init(__unchecked: (), rawValue: rawValue, labels: labels)
    }
}

extension RFC_1123.Domain {
    /// The complete host name as a string
    public var name: String {
        rawValue
    }

    /// The top-level domain (rightmost label)
    public var tld: Label? {
        labels.last
    }

    /// The second-level domain (second from right)
    public var sld: Label? {
        labels.dropLast().last
    }
}

extension RFC_1123.Domain {
    /// Returns true if this is a subdomain of the given host
    public func isSubdomain(of parent: RFC_1123.Domain) -> Bool {
        guard labels.count > parent.labels.count else { return false }
        return labels.suffix(parent.labels.count) == parent.labels
    }

    /// Creates a subdomain by prepending new labels
    public func addingSubdomain(_ components: [String]) throws(Error) -> RFC_1123.Domain {
        var newLabels: [Label] = []
        for component in components {
            do {
                newLabels.append(try Label(ascii: Array<Byte>(component.utf8)))
            } catch {
                throw Error.invalidLabel(error)
            }
        }

        let allLabels = newLabels + labels
        guard allLabels.count <= Limits.maxLabels else {
            throw Error.tooManyLabels
        }

        let newName = (components + labels.map(\.rawValue)).joined(separator: ".")
        guard newName.count <= Limits.maxLength else {
            throw Error.tooLong(newName.count)
        }

        return RFC_1123.Domain(__unchecked: (), rawValue: newName, labels: allLabels)
    }

    /// Creates a subdomain by prepending new labels
    public func addingSubdomain(_ components: String...) throws(Error) -> RFC_1123.Domain {
        try self.addingSubdomain(components)
    }

    /// Returns the parent domain by removing the leftmost label
    public func parent() -> RFC_1123.Domain? {
        guard labels.count > 1 else { return nil }
        let parentLabels = Array(labels.dropFirst())
        let parentName = parentLabels.map(\.rawValue).joined(separator: ".")
        return RFC_1123.Domain(__unchecked: (), rawValue: parentName, labels: parentLabels)
    }

    /// Returns the root domain (tld + sld)
    public func root() -> RFC_1123.Domain? {
        guard labels.count >= 2 else { return nil }
        let rootLabels = Array(labels.suffix(2))
        let rootName = rootLabels.map(\.rawValue).joined(separator: ".")
        return RFC_1123.Domain(__unchecked: (), rawValue: rootName, labels: rootLabels)
    }
}

extension RFC_1123.Domain {
    /// Initialize with an array of validated labels
    ///
    /// Note: This will validate that the last label (TLD) starts with a letter.
    public init(labels: [Label]) throws(Error) {
        guard !labels.isEmpty else {
            throw Error.empty
        }

        guard labels.count <= Limits.maxLabels else {
            throw Error.tooManyLabels
        }

        let name = labels.map(\.rawValue).joined(separator: ".")
        guard name.count <= Limits.maxLength else {
            throw Error.tooLong(name.count)
        }

        // RFC 1123 Section 2.1:
        // "the highest-level component label will be alphabetic"
        if let tld = labels.last {
            guard tld.rawValue.utf8.allSatisfy({ ASCII.Code(Byte($0)).isLetter }) else {
                throw Error.invalidTLD(tld.rawValue)
            }
        }

        self.init(__unchecked: (), rawValue: name, labels: labels)
    }

    /// Creates a host from root level components
    public static func root(_ sld: String, _ tld: String) throws(Error) -> RFC_1123.Domain {
        let sldLabel: Label
        let tldLabel: Label
        do {
            sldLabel = try Label(sld)
        } catch {
            throw Error.invalidLabel(error)
        }
        do {
            tldLabel = try Label(tld)
        } catch {
            throw Error.invalidLabel(error)
        }
        return try RFC_1123.Domain(labels: [sldLabel, tldLabel])
    }

    /// Creates a subdomain with components in most-to-least significant order
    public static func subdomain(_ components: String...) throws(Error) -> RFC_1123.Domain {
        guard !components.isEmpty else {
            throw Error.empty
        }

        var labels: [Label] = []
        for label in components.reversed() {
            do {
                labels.append(try Label(label))
            } catch {
                throw Error.invalidLabel(error)
            }
        }

        return try RFC_1123.Domain(labels: labels)
    }
}
