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

extension StringProtocol {
    /// Creates string representation of an RFC 1123 domain label
    ///
    /// RFC 1123 domain labels are pure ASCII (7-bit), and this initializer
    /// interprets them as UTF-8 (since ASCII ⊂ UTF-8).
    ///
    /// - Parameter label: The domain label to represent
    public init(_ label: RFC_1123.Domain.Label) {
        self = Self(decoding: [UInt8](label), as: UTF8.self)
    }
}

// MARK: - Domain String Representation

extension StringProtocol {
    /// Creates string representation of an RFC 1123 domain name
    ///
    /// RFC 1123 domain names are pure ASCII (7-bit), and this initializer
    /// interprets them as UTF-8 (since ASCII ⊂ UTF-8).
    ///
    /// - Parameter domain: The domain name to represent
    public init(_ domain: RFC_1123.Domain) {
        self = Self(decoding: [UInt8](domain), as: UTF8.self)
    }
}
