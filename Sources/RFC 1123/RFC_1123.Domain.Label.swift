//
//  RFC_1123.Domain.Label.swift
//  swift-rfc-1123
//
//  Created by Coen ten Thije Boonkkamp on 21/11/2025.
//

public import INCITS_4_1986

extension RFC_1123.Domain {
    /// RFC 1123 compliant host label
    ///
    /// Represents a single label within a host name as defined by RFC 1123 Section 2.1.
    /// Labels are case-insensitive ASCII strings that can start with letters or digits.
    ///
    /// ## RFC 1123 Constraints
    ///
    /// Per RFC 1123 Section 2.1:
    /// - Must be 1-63 octets long
    /// - Can start with letter or digit (relaxed from RFC 1035)
    /// - Must end with a letter or digit
    /// - May contain letters, digits, and hyphens
    ///
    /// Note: The RFC 1123 constraint that "the highest-level component label will be alphabetic"
    /// is enforced at the Domain level, not here, since it's a positional constraint about where
    /// the label appears in a hostname, not a grammar rule about label syntax.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let label = try RFC_1123.Domain.Label("3com")  // Valid
    /// let label2 = try RFC_1123.Domain.Label("com")  // Valid
    /// ```
    public struct Label: Sendable, Codable {
        /// The label value
        public let rawValue: String

        /// Creates a label WITHOUT validation
        ///
        /// **Warning**: Bypasses RFC 1123 validation.
        /// Only use with compile-time constants or pre-validated values.
        ///
        /// - Parameters:
        ///   - unchecked: Void parameter to prevent accidental use
        ///   - rawValue: The raw label value (unchecked)
        init(
            __unchecked: Void,
            rawValue: String
        ) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - Hashable

extension RFC_1123.Domain.Label: Hashable {
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

// MARK: - Serializing

extension RFC_1123.Domain.Label: UInt8.ASCII.Serializing {
    public static let serialize: @Sendable (Self) -> [UInt8] = [UInt8].init

    /// Parses a host label from canonical byte representation (CANONICAL PRIMITIVE)
    ///
    /// This is the primitive parser that works at the byte level.
    /// RFC 1123 host labels are ASCII-only.
    ///
    /// ## RFC 1123 Compliance
    ///
    /// Per RFC 1123 Section 2.1:
    /// - Labels must be 1-63 octets
    /// - Can start with letter or digit (relaxed from RFC 1035)
    /// - Must end with a letter or digit
    /// - May contain letters, digits, and hyphens
    ///
    /// ## Category Theory
    ///
    /// This is the fundamental parsing transformation:
    /// - **Domain**: [UInt8] (ASCII bytes)
    /// - **Codomain**: RFC_1123.Domain.Label (structured data)
    ///
    /// String-based parsing is derived as composition:
    /// ```
    /// String → [UInt8] (UTF-8 bytes) → Domain.Label
    /// ```
    ///
    /// ## Example
    ///
    /// ```swift
    /// let bytes = Array("3com".utf8)
    /// let label = try RFC_1123.Domain.Label(ascii: bytes)
    /// ```
    ///
    /// - Parameter bytes: The ASCII byte representation of the label
    /// - Throws: `RFC_1123.Domain.Label.Error` if the bytes are malformed
    public init<Bytes: Collection>(ascii bytes: Bytes, in context: Void) throws(Error)
    where Bytes.Element == UInt8 {
        guard let firstByte = bytes.first else {
            throw Error.empty
        }

        var count = 0
        var lastByte = firstByte

        for byte in bytes {
            count += 1
            lastByte = byte

            let valid = byte.ascii.isLetter || byte.ascii.isDigit || byte == .ascii.hyphen
            guard valid else {
                let string = String(decoding: bytes, as: UTF8.self)
                throw Error.invalidCharacters(
                    string,
                    byte: byte,
                    reason: "Only letters, digits, and hyphens allowed"
                )
            }
        }

        guard count <= RFC_1123.Domain.Limits.maxLabelLength else {
            let string = String(decoding: bytes, as: UTF8.self)
            throw Error.tooLong(count, label: string)
        }

        // RFC 1123: Can start with letter or digit
        guard firstByte.ascii.isLetter || firstByte.ascii.isDigit else {
            let string = String(decoding: bytes, as: UTF8.self)
            throw Error.invalidCharacters(
                string,
                byte: firstByte,
                reason: "Must start with a letter or digit"
            )
        }

        // Must end with a letter or digit
        guard lastByte.ascii.isLetter || lastByte.ascii.isDigit else {
            let string = String(decoding: bytes, as: UTF8.self)
            throw Error.invalidCharacters(
                string,
                byte: lastByte,
                reason: "Must end with a letter or digit"
            )
        }

        self.init(__unchecked: (), rawValue: String(decoding: bytes, as: UTF8.self))
    }
}

// MARK: - Byte Serialization

extension [UInt8] {
    /// Creates ASCII byte representation of an RFC 1123 host label
    ///
    /// This is the canonical serialization of host labels to bytes.
    /// RFC 1123 host labels are ASCII-only by definition.
    ///
    /// ## Category Theory
    ///
    /// This is the most universal serialization (natural transformation):
    /// - **Domain**: RFC_1123.Domain.Label (structured data)
    /// - **Codomain**: [UInt8] (ASCII bytes)
    ///
    /// String representation is derived as composition:
    /// ```
    /// Domain.Label → [UInt8] (ASCII) → String (UTF-8 interpretation)
    /// ```
    ///
    /// ## Example
    ///
    /// ```swift
    /// let label = try RFC_1123.Domain.Label("3com")
    /// let bytes = [UInt8](label)
    /// // bytes == "3com" as ASCII bytes
    /// ```
    ///
    /// - Parameter label: The host label to serialize
    public init(_ label: RFC_1123.Domain.Label) {
        self = Array(label.rawValue.utf8)
    }
}

// MARK: - Protocol Conformances

extension RFC_1123.Domain.Label: UInt8.ASCII.RawRepresentable {}
extension RFC_1123.Domain.Label: CustomStringConvertible {}
