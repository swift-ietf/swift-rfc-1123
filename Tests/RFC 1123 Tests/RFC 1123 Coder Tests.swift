#if Coder
    import Byte
    import Coder
    import Cursor
    import Parser
    import RFC_1123
    import Serializer
    import Testing

    @Suite
    struct `RFC 1123 Coder Tests` {
        @Suite struct `Domain Tests` {}
        @Suite struct `Label Tests` {}
    }

    extension `RFC 1123 Coder Tests`.`Domain Tests` {

        @Test
        func `reads a host name and stops at the port colon`() throws {
            var input: ArraySlice<Byte> = "host.example.com:8080"
            #expect(try RFC_1123.Domain.coder.parse(&input) == "host.example.com")
            #expect(input.first == Byte(bitPattern: 0x3A))
        }

        @Test
        func `reads an absolute host name and leaves the trailing dot`() throws {
            var input: ArraySlice<Byte> = "example.com."
            #expect(try RFC_1123.Domain.coder.parse(&input) == "example.com")
            #expect(input.first == Byte(bitPattern: 0x2E))
            #expect(input.count == 1)
        }

        @Test
        func `reads an absolute host name and stops before the dot and port`() throws {
            var input: ArraySlice<Byte> = "example.com.:80"
            #expect(try RFC_1123.Domain.coder.parse(&input) == "example.com")
            #expect(input.count == 4)
        }

        @Test
        func `reads a digit-led label and stops at whitespace`() throws {
            var input: ArraySlice<Byte> = "123.example.com rest"
            let domain = try RFC_1123.Domain.coder.parse(&input)
            #expect(domain.name == "123.example.com")
            #expect(domain.tld! == "com")
            #expect(input.first == Byte(bitPattern: 0x20))
        }

        @Test
        func `rejects a digit-led top-level domain and restores the cursor`() {
            var input: ArraySlice<Byte> = "example.123com>"
            #expect(throws: RFC_1123.Domain.Error.invalidTLD("123com")) {
                try RFC_1123.Domain.coder.parse(&input)
            }
            #expect(input.count == 15)
        }

        @Test
        func `rejects an empty label and restores the cursor`() {
            var input: ArraySlice<Byte> = "www..com"
            #expect(throws: RFC_1123.Domain.Error.invalidLabel(.empty)) {
                try RFC_1123.Domain.coder.parse(&input)
            }
            #expect(input.count == 8)
        }

        @Test
        func `rejects input that does not start with a domain byte`() {
            var input: ArraySlice<Byte> = "@example.com"
            #expect(throws: RFC_1123.Domain.Error.empty) {
                try RFC_1123.Domain.coder.parse(&input)
            }
            #expect(input.count == 12)
        }

        @Test
        func `round-trips through its text form`() throws {
            let domain = try RFC_1123.Domain("api.v1.example.com")
            #expect(try RFC_1123.Domain.coder.serialize(domain) == "api.v1.example.com")
        }

        @Test
        func `decodes through the domain coder`() throws {
            var input: ArraySlice<Byte> = "example.com"
            let domain = try RFC_1123.Domain.coder.parse(&input)
            #expect(domain.sld! == "example")
            #expect(input.isEmpty)
        }
    }

    extension `RFC 1123 Coder Tests`.`Label Tests` {

        @Test
        func `reads a label and stops at the dot`() throws {
            var input: ArraySlice<Byte> = "host.example.com"
            #expect(try RFC_1123.Domain.Label.coder.parse(&input) == "host")
            #expect(input.first == Byte(bitPattern: 0x2E))
        }

        @Test
        func `accepts interior hyphens`() throws {
            var input: ArraySlice<Byte> = "xn--p1ai."
            #expect(try RFC_1123.Domain.Label.coder.parse(&input).rawValue == "xn--p1ai")
        }

        @Test
        func `rejects a leading hyphen and restores the cursor`() {
            var input: ArraySlice<Byte> = "-bad."
            #expect(throws: RFC_1123.Domain.Label.Error.self) {
                try RFC_1123.Domain.Label.coder.parse(&input)
            }
            #expect(input.count == 5)
        }

        @Test
        func `rejects empty input`() {
            var input: ArraySlice<Byte> = ".com"
            #expect(throws: RFC_1123.Domain.Label.Error.empty) {
                try RFC_1123.Domain.Label.coder.parse(&input)
            }
        }

        @Test
        func `round-trips through its text form`() throws {
            let label = try RFC_1123.Domain.Label("3com")
            #expect(try RFC_1123.Domain.Label.coder.serialize(label) == "3com")
        }
    }
#endif
