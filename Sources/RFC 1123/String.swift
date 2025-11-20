// ===----------------------------------------------------------------------===//
//
// Copyright (c) 2025 Coen ten Thije Boonkkamp
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of project contributors
//
// SPDX-License-Identifier: Apache-2.0
//
// ===----------------------------------------------------------------------===//

// String.swift
// swift-rfc-1123
//
// String representations composed through canonical byte serialization

// MARK: - Label String Representation

extension String {
    /// Creates string representation of an RFC 1123 domain label using UTF-8 encoding
    ///
    /// This is the canonical string representation that composes through bytes.
    ///
    /// ## Category Theory
    ///
    /// This is functor composition through the canonical byte representation:
    /// ```
    /// Domain.Label → [UInt8] (ASCII) → String (UTF-8 interpretation)
    /// ```
    ///
    /// ASCII is a subset of UTF-8, so this conversion is always safe.
    ///
    /// - Parameter label: The domain label to represent
    public init(_ label: RFC_1123.Domain.Label) {
        self.init(decoding: [UInt8](label), as: UTF8.self)
    }

    /// Creates string representation of an RFC 1123 domain label using a custom encoding
    ///
    /// Use this initializer when you need to decode the label bytes with a specific
    /// encoding other than UTF-8.
    ///
    /// - Parameters:
    ///   - label: The domain label to represent
    ///   - encoding: The Unicode encoding to use for decoding
    public init<Encoding>(_ label: RFC_1123.Domain.Label, as encoding: Encoding.Type) where Encoding: _UnicodeEncoding, Encoding.CodeUnit == UInt8 {
        self = String(decoding: [UInt8](label), as: encoding)
    }
}

// MARK: - Domain String Representation

extension String {
    /// Creates string representation of an RFC 1123 domain name using UTF-8 encoding
    ///
    /// This is the canonical string representation that composes through bytes.
    ///
    /// ## Category Theory
    ///
    /// This is functor composition - the String transformation is derived from
    /// the more universal [UInt8] transformation:
    /// ```
    /// Domain → [UInt8] (ASCII) → String (UTF-8 interpretation)
    /// ```
    ///
    /// ASCII is a subset of UTF-8, so this conversion is always safe.
    ///
    /// - Parameter domain: The domain name to represent
    public init(_ domain: RFC_1123.Domain) {
        self.init(decoding: [UInt8](domain), as: UTF8.self)
    }

    /// Creates string representation of an RFC 1123 domain name using a custom encoding
    ///
    /// Use this initializer when you need to decode the domain bytes with a specific
    /// encoding other than UTF-8.
    ///
    /// - Parameters:
    ///   - domain: The domain name to represent
    ///   - encoding: The Unicode encoding to use for decoding
    public init<Encoding>(_ domain: RFC_1123.Domain, as encoding: Encoding.Type) where Encoding: _UnicodeEncoding, Encoding.CodeUnit == UInt8 {
        self = String(decoding: [UInt8](domain), as: encoding)
    }
}
