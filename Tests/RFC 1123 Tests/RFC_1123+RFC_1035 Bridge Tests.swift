//
//  RFC_1123+RFC_1035 Bridge Tests.swift
//  swift-rfc-1123
//
//  Regression tests for the RFC 1035 -> RFC 1123 bridge: wire-decoded
//  RFC 1035 domains may carry octets outside the RFC 1123 alphabet
//  (stored in RFC 1035 Section 5.1 escaped presentation form) and must
//  be rejected by RFC_1123.Domain's strict initializer.
//

import RFC_1035
import RFC_1123
import Testing

@Suite
struct `RFC 1035 Bridge` {

    /// Builds an RFC 1035 domain via the public wire-decoding path
    /// (`RFC_1035.Message.init(binary:)`) so labels bypass presentation
    /// validation, exactly as names decoded off the DNS wire do.
    private func wireDecodedDomain(labels: [[UInt8]]) throws -> RFC_1035.Domain {
        var bytes: [UInt8] = [
            0x00, 0x01,  // ID
            0x00, 0x00,  // flags
            0x00, 0x01,  // QDCOUNT = 1
            0x00, 0x00,  // ANCOUNT
            0x00, 0x00,  // NSCOUNT
            0x00, 0x00,  // ARCOUNT
        ]
        for label in labels {
            bytes.append(UInt8(label.count))
            bytes.append(contentsOf: label)
        }
        bytes.append(0x00)  // root
        bytes.append(contentsOf: [0x00, 0x01])  // QTYPE = A
        bytes.append(contentsOf: [0x00, 0x01])  // QCLASS = IN
        let message = try RFC_1035.Message(binary: bytes.map(Byte.init))
        return try #require(message.questions.first).name
    }

    @Test
    func `Wire-decoded underscore label fails RFC 1123 conversion`() throws {
        let domain = try wireDecodedDomain(labels: [
            Array("_dmarc".utf8),
            Array("example".utf8),
            Array("com".utf8),
        ])
        #expect(domain.name == "_dmarc.example.com")

        #expect(throws: RFC_1123.Domain.Error.self) {
            try RFC_1123.Domain(domain)
        }
    }

    @Test
    func `Presentation-valid wire-decoded domain converts`() throws {
        let domain = try wireDecodedDomain(labels: [
            Array("example".utf8),
            Array("com".utf8),
        ])

        let converted = try RFC_1123.Domain(domain)
        #expect(converted.name == "example.com")
    }
}
