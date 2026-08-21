import RFC_1035
import RFC_1123
import Testing

@Suite
struct `README Verification` {

    @Test
    func `README Line 53: Create from string`() throws {
        let host = try RFC_1123.Domain("example.com")

        #expect(host.name == "example.com")
    }

    @Test
    func `README Line 55-56: RFC 1123 allows labels starting with digits`() throws {
        let numericHost = try RFC_1123.Domain("123.example.com")

        #expect(numericHost.name == "123.example.com")
    }

    @Test
    func `README Line 58-59: Create from root components`() throws {
        let host = try RFC_1123.Domain.root("example", "com")

        #expect(host.name == "example.com")
    }

    @Test
    func `README Line 61-63: Create subdomain with reversed components`() throws {
        let host = try RFC_1123.Domain.subdomain("com", "example", "api")

        #expect(host.name == "api.example.com")
    }

    @Test
    func `README Line 69-76: Working with domain components`() throws {
        let host = try RFC_1123.Domain("api.example.com")

        #expect(host.tld! == "com")
        #expect(host.sld! == "example")
        #expect(host.name == "api.example.com")
    }

    @Test
    func `README Line 82-99: Domain hierarchy navigation`() throws {
        let host = try RFC_1123.Domain("api.v1.example.com")

        let parent = host.parent()
        #expect(parent?.name == "v1.example.com")

        let root = host.root()
        #expect(root?.name == "example.com")

        let subdomain = try host.addingSubdomain("staging")
        #expect(subdomain.name == "staging.api.v1.example.com")

        let parentDomain = try RFC_1123.Domain("example.com")
        let childDomain = try RFC_1123.Domain("api.example.com")
        #expect(childDomain.isSubdomain(of: parentDomain))
    }

    @Test
    func `README Line 105-113: RFC 1035 interoperability`() throws {

        let rfc1035Domain = try RFC_1035.Domain("example.com")
        let rfc1123Domain = try RFC_1123.Domain(rfc1035Domain)

        #expect(rfc1123Domain.name == "example.com")

        let backToRFC1035 = try RFC_1035.Domain(rfc1123Domain)

        #expect(backToRFC1035.name == "example.com")
    }

    @Test
    func `README Line 166-178: Error handling`() throws {

        #expect(throws: RFC_1123.Domain.Error.empty) {
            _ = try RFC_1123.Domain("")
        }

        #expect(throws: RFC_1123.Domain.Error.self) {
            _ = try RFC_1123.Domain("example.123com")
        }
    }
}
