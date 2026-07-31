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

// RFC_1123.Domain.Error.swift
// swift-rfc-1123
//
// Domain-level validation errors

// MARK: - Errors
extension RFC_1123.Domain {
    /// Errors that can occur during domain validation
    ///
    /// These represent compositional constraint violations at the domain level,
    /// as defined by RFC 1123 Section 2.1.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// Domain has no labels (empty string)
        case empty

        /// Domain exceeds maximum total length of 255 octets
        case tooLong(_ length: Int)

        /// Domain has more than 127 labels
        case tooManyLabels

        /// One or more labels failed validation
        case invalidLabel(_ error: Label.Error)

        /// The highest-level component label (TLD) does not start with a letter
        ///
        /// RFC 1123 Section 2.1 states: "a valid host name can never have the
        /// dotted-decimal form #.#.#.#, since at least the highest-level component
        /// label will be alphabetic."
        case invalidTLD(_ tld: String)
    }
}

// MARK: - CustomStringConvertible

extension RFC_1123.Domain.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .empty:
            return "Domain name cannot be empty"

        case .tooLong(let length):
            return "Domain name is too long (\(length) bytes, maximum 255)"

        case .tooManyLabels:
            return "Domain has too many labels (maximum 127)"

        case .invalidLabel(let error):
            return "Invalid label: \(error.description)"

        case .invalidTLD(let tld):
            return
                "Invalid TLD '\(tld)': highest-level component label must start with a letter (RFC 1123 Section 2.1)"
        }
    }
}
