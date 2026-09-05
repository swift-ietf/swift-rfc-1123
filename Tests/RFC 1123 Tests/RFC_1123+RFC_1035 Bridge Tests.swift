import Byte
import Byte_Standard_Library_Integration
import RFC_1035
import RFC_1123
import Testing

@Suite
struct `RFC 1035 Bridge` {

    @Test
    func `Octet-form underscore label fails RFC 1123 conversion`() throws {
        let domain = try RFC_1035.Domain(labels: [
            try .init(octets: [Byte](utf8: "_dmarc")),
            try .init("example"),
            try .init("com"),
        ])
        #expect(domain.name == "_dmarc.example.com")

        #expect(throws: RFC_1123.Domain.Error.self) {
            try RFC_1123.Domain(domain)
        }
    }

    @Test
    func `Presentation-valid octet-form domain converts`() throws {
        let domain = try RFC_1035.Domain(labels: [
            try .init(octets: [Byte](utf8: "example")),
            try .init(octets: [Byte](utf8: "com")),
        ])

        let converted = try RFC_1123.Domain(domain)
        #expect(converted.name == "example.com")
    }
}
