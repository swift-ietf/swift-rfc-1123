import RFC_1123
import Testing

enum `RFC_1123.Domain Tests` {}

extension `RFC_1123.Domain Tests` {
    @Suite struct `Edge Case` {

        @Test
        func `TLD containing digits after a leading letter is rejected`() throws {
            #expect(throws: RFC_1123.Domain.Error.invalidTLD("com123")) {
                _ = try RFC_1123.Domain("example.com123")
            }
        }

        @Test
        func `Uppercase punycode TLD is accepted`() throws {
            let domain = try RFC_1123.Domain("example.XN--P1AI")
            #expect(domain.tld! == "xn--p1ai")
        }

        @Test
        func `TLD containing a hyphen outside an A-label is rejected`() throws {
            #expect(throws: RFC_1123.Domain.Error.invalidTLD("co-m")) {
                _ = try RFC_1123.Domain("example.co-m")
            }
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
        func `Labels initializer rejects TLD containing digits after a leading letter`() throws {
            let tld = try RFC_1123.Domain.Label("com123")
            let sld = try RFC_1123.Domain.Label("example")
            #expect(throws: RFC_1123.Domain.Error.invalidTLD("com123")) {
                _ = try RFC_1123.Domain(labels: [sld, tld])
            }
        }

        @Test
        func `Labels initializer rejects TLD starting with a digit`() throws {
            let tld = try RFC_1123.Domain.Label("3com")
            let sld = try RFC_1123.Domain.Label("example")
            #expect(throws: RFC_1123.Domain.Error.invalidTLD("3com")) {
                _ = try RFC_1123.Domain(labels: [sld, tld])
            }
        }

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
    }
}
