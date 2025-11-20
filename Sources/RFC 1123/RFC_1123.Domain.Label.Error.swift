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

// RFC_1123.Domain.Label.Error.swift
// swift-rfc-1123
//
// Label-level validation errors

// MARK: - Errors
extension RFC_1123.Domain.Label {
    /// Errors that can occur during label validation
    ///
    /// These represent atomic constraint violations at the label level,
    /// as defined by RFC 1123 Section 2.1.
    public enum Error: Swift.Error, Equatable {
        /// Label is empty
        case empty

        /// Label exceeds maximum length of 63 octets
        case tooLong(_ length: Int, label: String)

        /// Label contains invalid characters for regular labels
        case invalidCharacters(_ label: String)

        /// TLD validation failed (must start with letter, end with letter)
        case invalidTLD(_ tld: String)
    }
}

// MARK: - CustomStringConvertible

extension RFC_1123.Domain.Label.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .empty:
            return "Domain label cannot be empty"
        case .tooLong(let length, let label):
            return "Domain label '\(label)' is too long (\(length) bytes, maximum 63)"
        case .invalidCharacters(let label):
            return "Domain label '\(label)' contains invalid characters"
        case .invalidTLD(let tld):
            return "Invalid TLD '\(tld)': must start with a letter and end with a letter"
        }
    }
}
