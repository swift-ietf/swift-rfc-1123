//
//  File.swift
//  swift-rfc-1123
//
//  Created by Coen ten Thije Boonkkamp on 19/11/2025.
//

extension String {
    public init(
        _ label: RFC_1123.Domain.Label
    ) {
        self = label.value
    }
}
