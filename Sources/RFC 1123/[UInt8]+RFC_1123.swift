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

// [UInt8]+Domain.swift
// swift-rfc-1123
//
// Canonical byte serialization for RFC 1123 domain names

import INCITS_4_1986
import Standards

// MARK: - Label Serialization

extension [UInt8] {
    /// Creates ASCII byte representation of an RFC 1123 domain label
    ///
    /// This is the canonical serialization of domain labels to bytes.
    /// RFC 1123 domain labels are ASCII-only by definition.
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
    /// ## Performance
    ///
    /// Zero-cost: Returns internal canonical byte storage directly.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let label = try RFC_1123.Domain.Label("example", validateAs: .label)
    /// let bytes = [UInt8](label)
    /// // bytes == [101, 120, 97, 109, 112, 108, 101]
    /// // ASCII:      'e'  'x'  'a'  'm'  'p'  'l'  'e'
    /// ```
    ///
    /// - Parameter label: The domain label to serialize
    public init(_ label: RFC_1123.Domain.Label) {
        // Zero-cost: direct access to canonical byte storage
        self = label._value
    }
}

// MARK: - Domain Serialization

extension [UInt8] {
    /// Creates ASCII byte representation of an RFC 1123 domain name
    ///
    /// This is the canonical serialization of domain names to bytes.
    /// The format is labels joined by dots (ASCII 0x2E):
    /// ```
    /// <label>.<label>.<label>
    /// ```
    ///
    /// ## Category Theory
    ///
    /// This is the most universal serialization (natural transformation):
    /// - **Domain**: RFC_1123.Domain (structured data)
    /// - **Codomain**: [UInt8] (ASCII bytes)
    ///
    /// String representation is derived as composition:
    /// ```
    /// Domain → [UInt8] (ASCII) → String (UTF-8 interpretation)
    /// ```
    ///
    /// ## Performance
    ///
    /// Efficient composition of label bytes:
    /// - Single allocation with capacity estimation
    /// - Direct byte array concatenation
    /// - No intermediate String allocations
    ///
    /// ## Example
    ///
    /// ```swift
    /// let domain = try RFC_1123.Domain("www.example.com")
    /// let bytes = [UInt8](domain)
    /// // bytes represents "www.example.com" as ASCII bytes
    /// ```
    ///
    /// - Parameter domain: The domain name to serialize
    public init(_ domain: RFC_1123.Domain) {
        self = []

        // Estimate capacity: average label length ~10 bytes + dots
        self.reserveCapacity(domain.labels.count * 11)

        for (index, label) in domain.labels.enumerated() {
            if index > 0 {
                self.append(.ascii.period)
            }
            self.append(contentsOf: label._value)
        }
    }
}
