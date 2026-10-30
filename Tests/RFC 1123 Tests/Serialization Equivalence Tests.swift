#if Coder
    import ASCII
    import Binary
    import Byte
    import RFC_1123
    import Testing

    @Suite
    struct `Serialization Equivalence` {

        private func expectEquivalent<T: ASCII.Serializable & Binary.Serializable>(
            _ value: T,
            _ label: Comment
        ) {
            var ascii: [ASCII.Code] = []
            T.serialize(value, into: &ascii)
            var wire: [Byte] = []
            T.serialize(value, into: &wire)
            #expect(ascii.map(\.byte) == wire, label)
        }

        @Test
        func `Domain verbs agree`() throws {
            expectEquivalent(try RFC_1123.Domain("example.com"), "example.com")
            expectEquivalent(try RFC_1123.Domain("123.example.com"), "123.example.com")
            expectEquivalent(try RFC_1123.Domain("example.xn--p1ai"), "example.xn--p1ai")
        }

        @Test
        func `Label verbs agree`() throws {
            expectEquivalent(try RFC_1123.Domain.Label("example"), "example")
            expectEquivalent(try RFC_1123.Domain.Label("3com"), "3com")
        }

        @Test
        func `serialized bytes spell the description`() throws {
            let domain = try RFC_1123.Domain("Host.Example.COM")
            var wire: [Byte] = []
            RFC_1123.Domain.serialize(domain, into: &wire)
            #expect(String(decoding: wire.map(\.bitPattern), as: UTF8.self) == domain.description)
        }
    }
#endif
