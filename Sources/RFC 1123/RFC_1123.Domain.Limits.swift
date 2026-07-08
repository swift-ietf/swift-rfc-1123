//
//  File.swift
//  swift-rfc-1123
//
//  Created by Coen ten Thije Boonkkamp on 28/11/2025.
//

extension RFC_1123.Domain {
    package enum Limits {
    }
}

extension RFC_1123.Domain.Limits {
    static let maxLength = 255
    static let maxLabels = 127
    static let maxLabelLength = 63
}
