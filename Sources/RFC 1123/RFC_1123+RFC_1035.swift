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
    /// RFC 1035 domains are a subset of RFC 1123 domains (labels must start with letters).
    /// This initializer always succeeds because RFC 1035 is stricter.
    public init(_ domain: RFC_1035.Domain) throws(Error) {
        try self.init(domain.name)
    }
}
