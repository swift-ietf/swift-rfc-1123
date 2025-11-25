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
