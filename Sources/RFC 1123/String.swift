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
    /// Creates string representation of an RFC 1123 domain label using a custom encoding
    ///
    /// Use this initializer when you need to decode the label bytes with a specific
    /// encoding other than UTF-8.
    ///
    /// - Parameters:
    ///   - label: The domain label to represent
    ///   - encoding: The Unicode encoding to use for decoding
    public init<Encoding>(
        _ label: RFC_1123.Domain.Label,
        as encoding: Encoding.Type = UTF8.self
    ) where Encoding: _UnicodeEncoding, Encoding.CodeUnit == UInt8 {
        self = String(decoding: [UInt8](label), as: encoding)
    }
}

// MARK: - Domain String Representation

extension String {
    /// Creates string representation of an RFC 1123 domain name using a custom encoding
    ///
    /// Use this initializer when you need to decode the domain bytes with a specific
    /// encoding other than UTF-8.
    ///
    /// - Parameters:
    ///   - domain: The domain name to represent
    ///   - encoding: The Unicode encoding to use for decoding
    public init<Encoding>(
        _ domain: RFC_1123.Domain,
        as encoding: Encoding.Type = UTF8.self
    ) where Encoding: _UnicodeEncoding, Encoding.CodeUnit == UInt8 {
        self = String(decoding: [UInt8](domain), as: encoding)
    }
}
