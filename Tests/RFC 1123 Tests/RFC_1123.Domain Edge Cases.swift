//
//  RFC_1123.Domain Edge Cases.swift
//  swift-rfc-1123
//
//  Fable-448 regression tests (F-001, F-002, F-003).
//

import Foundation
import RFC_1123
import Testing

extension RFC_1123.Domain {
    @Suite struct `Edge Case` {

        // MARK: - F-001: TLD rule is starts-with-letter, not all-alphabetic

        @Test
        func `TLD starting with a letter may contain digits`() throws {
            let domain = try RFC_1123.Domain("example.com123")
            #expect(domain.tld! == "com123")
        }

        @Test
        func `Punycode TLD is accepted`() throws {
            let domain = try RFC_1123.Domain("example.xn--p1ai")
            #expect(domain.tld! == "xn--p1ai")
        }

        @Test
        func `TLD starting with a digit is rejected`() throws {
            #expect(throws: RFC_1123.Domain.Error.invalidTLD("123com")) {
                _ = try RFC_1123.Domain("example.123com")
            }
        }

        @Test
        func `Labels initializer accepts TLD containing digits after a leading letter`() throws {
            let tld = try RFC_1123.Domain.Label("com123")
            let sld = try RFC_1123.Domain.Label("example")
            let domain = try RFC_1123.Domain(labels: [sld, tld])
            #expect(domain.name == "example.com123")
        }

        @Test
        func `Labels initializer rejects TLD starting with a digit`() throws {
            let tld = try RFC_1123.Domain.Label("3com")
            let sld = try RFC_1123.Domain.Label("example")
            #expect(throws: RFC_1123.Domain.Error.invalidTLD("3com")) {
                _ = try RFC_1123.Domain(labels: [sld, tld])
            }
        }

        // MARK: - F-002: empty labels must be rejected, not silently dropped

        @Test
        func `Leading dot is rejected`() throws {
            #expect(throws: RFC_1123.Domain.Error.invalidLabel(.empty)) {
                _ = try RFC_1123.Domain(".com")
            }
        }

        @Test
        func `Trailing dot is rejected`() throws {
            #expect(throws: RFC_1123.Domain.Error.invalidLabel(.empty)) {
                _ = try RFC_1123.Domain("com.")
            }
        }

        @Test
        func `Consecutive dots are rejected`() throws {
            #expect(throws: RFC_1123.Domain.Error.invalidLabel(.empty)) {
                _ = try RFC_1123.Domain("a..b.com")
            }
        }

        @Test
        func `Empty label after www is rejected`() throws {
            #expect(throws: RFC_1123.Domain.Error.invalidLabel(.empty)) {
                _ = try RFC_1123.Domain("www..com")
            }
        }

        @Test
        func `Lone dot is rejected`() throws {
            #expect(throws: RFC_1123.Domain.Error.invalidLabel(.empty)) {
                _ = try RFC_1123.Domain(".")
            }
        }

        // MARK: - F-003: Codable must validate on decode and use canonical string form

        @Test
        func `Encodes as a canonical JSON string`() throws {
            let domain = try RFC_1123.Domain("example.com")
            let data = try JSONEncoder().encode(domain)
            #expect(String(decoding: data, as: UTF8.self) == "\"example.com\"")
        }

        @Test
        func `Decodes from a canonical JSON string`() throws {
            let data = Data("\"host.example.com\"".utf8)
            let domain = try JSONDecoder().decode(RFC_1123.Domain.self, from: data)
            #expect(domain == "host.example.com")
            #expect(domain.tld! == "com")
        }

        @Test
        func `Decoding an invalid domain string throws`() throws {
            let data = Data("\"www..com\"".utf8)
            #expect(throws: Swift.DecodingError.self) {
                _ = try JSONDecoder().decode(RFC_1123.Domain.self, from: data)
            }
        }

        @Test
        func `Codable round trip preserves the domain`() throws {
            let original = try RFC_1123.Domain("www.3com.com")
            let data = try JSONEncoder().encode(original)
            let decoded = try JSONDecoder().decode(RFC_1123.Domain.self, from: data)
            #expect(decoded == original)
        }
    }
}

extension RFC_1123.Domain.Label {
    @Suite struct `Edge Case` {

        // MARK: - F-003: Codable must validate on decode and use canonical string form

        @Test
        func `Encodes as a canonical JSON string`() throws {
            let label = try RFC_1123.Domain.Label("example")
            let data = try JSONEncoder().encode(label)
            #expect(String(decoding: data, as: UTF8.self) == "\"example\"")
        }

        @Test
        func `Decoding an invalid label string throws`() throws {
            let data = Data("\"-bad-\"".utf8)
            #expect(throws: Swift.DecodingError.self) {
                _ = try JSONDecoder().decode(RFC_1123.Domain.Label.self, from: data)
            }
        }

        @Test
        func `Codable round trip preserves the label`() throws {
            let original = try RFC_1123.Domain.Label("3com")
            let data = try JSONEncoder().encode(original)
            let decoded = try JSONDecoder().decode(RFC_1123.Domain.Label.self, from: data)
            #expect(decoded == original)
        }
    }
}
