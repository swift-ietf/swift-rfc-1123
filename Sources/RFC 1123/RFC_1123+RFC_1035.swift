//
//  File.swift
//  swift-rfc-1123
//
//  Created by Coen ten Thije Boonkkamp on 21/11/2025.
//

public import RFC_1035

extension RFC_1035.Domain {
    public init(_ domain: RFC_1123.Domain) throws(RFC_1035.Domain.Error) {
        try self.init(domain.name)
    }
}

extension RFC_1123.Domain {
    /// Initialize from an RFC 1035 domain
    ///
    /// Conversion succeeds for presentation-validated RFC 1035 domains, whose
    /// preferred syntax (RFC 1035 Section 2.3.1) is a subset of RFC 1123.
    ///
    /// It throws for wire-decoded RFC 1035 domains: labels on the DNS wire may
    /// contain arbitrary octets, stored in Section 5.1 escaped presentation
    /// form (e.g. `_dmarc`, `\068`, `\.`), which fall outside the RFC 1123
    /// alphabet and are rejected by this initializer's strict validation.
    public init(_ domain: RFC_1035.Domain) throws(Error) {
        try self.init(domain.name)
    }
}
