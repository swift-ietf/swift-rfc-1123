#if Coder
    import Byte
    import RFC_1123
    import Testing

    @Suite
    struct `RFC 1123 length and hyphen boundaries` {
        private func slice(_ text: String) -> ArraySlice<Byte> {
            ArraySlice(Array(text.utf8).map(Byte.init(bitPattern:)))
        }

        @Test
        func `a 63-byte label is accepted`() throws {
            var input = slice(String(repeating: "a", count: 63))
            _ = try RFC_1123.Domain.Label.coder.parse(&input)
            #expect(input.isEmpty)
        }

        @Test
        func `a 64-byte label is rejected`() {
            var input = slice(String(repeating: "a", count: 64))
            #expect(throws: RFC_1123.Domain.Label.Error.self) { try RFC_1123.Domain.Label.coder.parse(&input) }
        }

        @Test
        func `a trailing hyphen is rejected`() {
            var input = slice("bad-")
            #expect(throws: RFC_1123.Domain.Label.Error.self) { try RFC_1123.Domain.Label.coder.parse(&input) }
        }

        @Test
        func `a 255-byte name is accepted and a 256-byte name is rejected`() throws {
            let full = String(repeating: "a", count: 63)
            let fits = [full, full, full, full].joined(separator: ".")
            let over = [full, full, full, String(repeating: "b", count: 62), "c"].joined(separator: ".")
            #expect(fits.utf8.count == 255)
            #expect(over.utf8.count == 256)
            var input = slice(fits)
            _ = try RFC_1123.Domain.coder.parse(&input)
            #expect(input.isEmpty)
            var tooLong = slice(over)
            #expect(throws: (any Error).self) { try RFC_1123.Domain.coder.parse(&tooLong) }
        }
    }
#endif
