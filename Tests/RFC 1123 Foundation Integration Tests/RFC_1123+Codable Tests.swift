import Foundation
import RFC_1123
import RFC_1123_Foundation_Integration
import Testing

@Suite
struct `RFC_1123+Codable Tests` {

    @Test
    func `a domain codes as its text form`() async throws {
        let domain = try RFC_1123.Domain("example.com")

        let encoded = try JSONEncoder().encode(domain)

        #expect(String(decoding: encoded, as: UTF8.self) == #""example.com""#)
        #expect(try JSONDecoder().decode(RFC_1123.Domain.self, from: encoded) == domain)
    }

    @Test
    func `a decoded domain keeps its labels`() async throws {
        let encoded = Data(#""host.example.com""#.utf8)

        let domain = try JSONDecoder().decode(RFC_1123.Domain.self, from: encoded)

        #expect(domain == "host.example.com")
        #expect(domain.tld! == "com")
    }

    @Test
    func `a malformed domain fails to decode`() async throws {
        let encoded = Data(#""www..com""#.utf8)

        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(RFC_1123.Domain.self, from: encoded)
        }
    }

    @Test
    func `a domain with a digit-led label round-trips`() async throws {
        let domain = try RFC_1123.Domain("www.3com.com")

        let encoded = try JSONEncoder().encode(domain)

        #expect(try JSONDecoder().decode(RFC_1123.Domain.self, from: encoded) == domain)
    }

    @Test
    func `a label codes as its text form`() async throws {
        let label = try RFC_1123.Domain.Label("example")

        let encoded = try JSONEncoder().encode(label)

        #expect(String(decoding: encoded, as: UTF8.self) == #""example""#)
        #expect(try JSONDecoder().decode(RFC_1123.Domain.Label.self, from: encoded) == label)
    }

    @Test
    func `a malformed label fails to decode`() async throws {
        let encoded = Data(#""-bad-""#.utf8)

        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(RFC_1123.Domain.Label.self, from: encoded)
        }
    }

    @Test
    func `a digit-led label round-trips`() async throws {
        let label = try RFC_1123.Domain.Label("3com")

        let encoded = try JSONEncoder().encode(label)

        #expect(try JSONDecoder().decode(RFC_1123.Domain.Label.self, from: encoded) == label)
    }
}
