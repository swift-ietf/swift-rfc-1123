//
//  RFC_1123.Domain.Label.swift
//  swift-rfc-1123
//
//  Created by Coen ten Thije Boonkkamp on 21/11/2025.
//

public import ASCII_Serializer_Primitives
public import Binary_Serializable_Primitives
public import Parseable_ASCII_Primitives

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
    public struct Label: Sendable {
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

// MARK: - Serializable

extension RFC_1123.Domain.Label: Swift.RawRepresentable, ASCII.Serializable, Binary.Serializable {
    /// Creates a label by validating `rawValue`, or `nil` if it is not a valid RFC 1123 label.
    ///
    /// Re-provides the `Swift.RawRepresentable` requirement (previously inherited
    /// from the retired combined ASCII serializable protocol).
    public init?(rawValue: String) {
        do throws(Error) {
            try self.init(rawValue)
        } catch {
            return nil
        }
    }

    /// Serializes `value` as ASCII bytes into `buffer` (own `ASCII.Serializable` verb).
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == ASCII.Code {
        for byte in value.rawValue.utf8 { buffer.append(ASCII.Code(byte)) }
    }

    /// Serializes `value` as ASCII bytes into `buffer`.
    ///
    /// Explicit `Binary.Serializable` witness: disambiguates the two
    /// constraint-incomparable `serialize(_:into:)` defaults (the RawRepresentable
    /// default vs the W0 ASCII bridge) — a conformer-declared member out-ranks both.
    ///
    /// The bytes derive from the free `[ASCII.Code]` serializer supplied by the
    /// `String`-RawRepresentable default (`.serialized`).
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        buffer.append(contentsOf: value.serialized)
    }
}

extension RFC_1123.Domain.Label: Codable {
    /// Decodes a label from its canonical string form, validating it.
    ///
    /// Decoding goes through the validating parser, so a payload that is not a
    /// valid RFC 1123 label fails with `DecodingError.dataCorrupted`.
    ///
    /// Exact `Decodable` protocol requirement signature (stdlib); can express
    /// neither a generic parameter nor `throws(E)`.
    public init(
        from decoder: any Decoder  // swiftlint:disable:this no_any_protocol_existential
    ) throws {  // swiftlint:disable:this typed_throws_required
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        do {
            try self.init(string)
        } catch {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Invalid RFC 1123 label: \(error.description)"
                )
            )
        }
    }

    /// Encodes the label as its canonical string form.
    ///
    /// Exact `Encodable` protocol requirement signature (stdlib); can express
    /// neither a generic parameter nor `throws(E)`.
    public func encode(
        to encoder: any Encoder  // swiftlint:disable:this no_any_protocol_existential
    ) throws {  // swiftlint:disable:this typed_throws_required
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension RFC_1123.Domain.Label: CustomStringConvertible {
    /// The label's ASCII serialization decoded as a `String`.
    public var description: String {
        String(decoding: serialized, as: UTF8.self)
    }
}

extension RFC_1123.Domain.Label: ASCII.Parseable {
    /// Creates a label by validating `string`'s UTF-8 bytes as ASCII.
    ///
    /// Re-provides the string convenience initializer (previously inherited from
    /// the retired combined ASCII serializable protocol, Void context).
    public init(_ string: some StringProtocol) throws(Error) {
        try self.init(ascii: [Byte](string.utf8))
    }

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
    public init<Bytes: Swift.Collection>(ascii bytes: Bytes) throws(Error)
    where Bytes.Element == Byte {
        guard let firstByte = bytes.first else {
            throw Error.empty
        }

        var count = 0
        var lastByte = firstByte

        for byte in bytes {
            count += 1
            lastByte = byte

            // A byte outside the 7-bit ASCII range cannot be a valid label
            // character; ASCII.Code(_:) throws for it, mapping to the same
            // invalid-character error as a wrong-category ASCII byte.
            let code: ASCII.Code
            do throws(ASCII.Code.Error) {
                code = try ASCII.Code(byte)
            } catch {
                let string = String(decoding: bytes, as: UTF8.self)
                throw Error.invalidCharacters(
                    string,
                    byte: byte,
                    reason: "Only letters, digits, and hyphens allowed"
                )
            }
            let valid = code.isLetter || code.isDigit || code == ASCII.Code.hyphen
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
        // A non-ASCII first byte cannot start a label; map ASCII.Code(_:)'s
        // throw to the same "must start with a letter or digit" error.
        let firstCode: ASCII.Code
        do throws(ASCII.Code.Error) {
            firstCode = try ASCII.Code(firstByte)
        } catch {
            let string = String(decoding: bytes, as: UTF8.self)
            throw Error.invalidCharacters(
                string,
                byte: firstByte,
                reason: "Must start with a letter or digit"
            )
        }
        guard firstCode.isLetter || firstCode.isDigit else {
            let string = String(decoding: bytes, as: UTF8.self)
            throw Error.invalidCharacters(
                string,
                byte: firstByte,
                reason: "Must start with a letter or digit"
            )
        }

        // Must end with a letter or digit
        // A non-ASCII last byte cannot end a label; map ASCII.Code(_:)'s throw
        // to the same "must end with a letter or digit" error.
        let lastCode: ASCII.Code
        do throws(ASCII.Code.Error) {
            lastCode = try ASCII.Code(lastByte)
        } catch {
            let string = String(decoding: bytes, as: UTF8.self)
            throw Error.invalidCharacters(
                string,
                byte: lastByte,
                reason: "Must end with a letter or digit"
            )
        }
        guard lastCode.isLetter || lastCode.isDigit else {
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
