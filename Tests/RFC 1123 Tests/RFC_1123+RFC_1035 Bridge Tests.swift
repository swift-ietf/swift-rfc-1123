import Byte
import RFC_1035
import RFC_1123
import Testing

@Suite
struct `RFC 1035 Bridge` {

    private func wireDecodedDomain(labels: [[UInt8]]) throws -> RFC_1035.Domain {
        var bytes: [UInt8] = [
            0x00, 0x01,
            0x00, 0x00,
            0x00, 0x01,
            0x00, 0x00,
            0x00, 0x00,
            0x00, 0x00,
        ]
        for label in labels {
            bytes.append(UInt8(label.count))
            bytes.append(contentsOf: label)
        }
        bytes.append(0x00)
        bytes.append(contentsOf: [0x00, 0x01])
        bytes.append(contentsOf: [0x00, 0x01])
        let message = try RFC_1035.Message(binary: bytes.map(Byte.init(bitPattern:)))
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
