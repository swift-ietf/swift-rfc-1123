import RFC_1123
import Testing

@Suite
struct `RFC 1123 Tests` {

    @Test
    func `a domain is built from its text form`() throws {
        let domain = try RFC_1123.Domain("host.example.com")

        #expect(domain.name == "host.example.com")
    }

    @Test
    func `a digit-led label is accepted`() throws {
        let domain = try RFC_1123.Domain("123.example.com")

        #expect(domain.name == "123.example.com")
    }

    @Test
    func `mixed alphanumeric labels are accepted`() throws {
        let domain = try RFC_1123.Domain("host123.example456.com")

        #expect(domain.name == "host123.example456.com")
    }

    @Test
    func `an empty domain is rejected`() throws {
        #expect(throws: RFC_1123.Domain.Error.empty) {
            _ = try RFC_1123.Domain("")
        }
    }

    @Test
    func `a digit-led top-level domain is rejected`() throws {
        #expect(throws: RFC_1123.Domain.Error.invalidTLD("123com")) {
            _ = try RFC_1123.Domain("example.123com")
        }
    }

    @Test
    func `a top-level domain ending in a digit is accepted`() throws {
        let domain = try RFC_1123.Domain("example.com123")

        #expect(domain.tld! == "com123")
    }

    @Test
    func `a label with a special character is rejected`() throws {
        #expect(throws: RFC_1123.Domain.Error.self) {
            _ = try RFC_1123.Domain("host@name.com")
        }
    }

    @Test
    func `a domain exposes its top-level and second-level labels`() throws {
        let domain = try RFC_1123.Domain("example.com")

        #expect(domain.tld! == "com")
        #expect(domain.sld! == "example")
    }

    @Test
    func `a child domain is a subdomain of its parent`() throws {
        let parent = try RFC_1123.Domain("example.com")
        let child = try RFC_1123.Domain("host.example.com")

        #expect(child.isSubdomain(of: parent))
    }

    @Test
    func `a subdomain is added in front of the domain`() throws {
        let domain = try RFC_1123.Domain("example.com")

        let subdomain = try domain.addingSubdomain("host")

        #expect(subdomain.name == "host.example.com")
    }

    @Test
    func `a domain walks up to its parent and root`() throws {
        let domain = try RFC_1123.Domain("api.v1.example.com")

        #expect(domain.parent()?.name == "v1.example.com")
        #expect(domain.root()?.name == "example.com")
    }

    @Test
    func `a domain is built from root components`() throws {
        let domain = try RFC_1123.Domain.root("example", "com")

        #expect(domain.name == "example.com")
    }

    @Test
    func `a domain is built from reversed subdomain components`() throws {
        let domain = try RFC_1123.Domain.subdomain("com", "example", "host")

        #expect(domain.name == "host.example.com")
    }
}
