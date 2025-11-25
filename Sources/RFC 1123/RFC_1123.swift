//
//  RFC_1123.swift
//  swift-rfc-1123
//
//  Created by Coen ten Thije Boonkkamp on 28/12/2024.
//

/// RFC 1123: Requirements for Internet Hosts - Application and Support
///
/// This module provides Swift types for RFC 1123 compliant host names.
///
/// ## Overview
///
/// RFC 1123 relaxes RFC 1035's domain name syntax to allow labels that begin
/// with digits, making it more suitable for modern hostname validation.
///
/// Key differences from RFC 1035:
/// - Labels CAN start with digits (e.g., "3com.com")
/// - TLDs MUST still start with a letter
/// - All other RFC 1035 rules apply
///
/// ## Example
///
/// ```swift
/// let host = try RFC_1123.Domain("www.3com.com")  // Valid in RFC 1123
/// let tld = host.tld // "com"
/// ```
///
/// ## RFC Reference
///
/// - [RFC 1123 Section 2.1](https://www.rfc-editor.org/rfc/rfc1123#section-2.1)
public enum RFC_1123 {}
