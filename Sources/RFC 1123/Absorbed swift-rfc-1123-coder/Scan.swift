#if Coder
    import ASCII
    import Byte
    import Cursor

    enum Scan {}

    extension Scan {
        static func run<Input: Cursor.`Protocol`<Byte, Never>>(
            _ input: inout Input,
            while predicate: (Byte) -> Bool
        ) -> [Byte] {
            var bytes: [Byte] = []
            while true {
                let mark = input.checkpoint
                guard let byte = input.next(), predicate(byte) else {
                    input.seek(to: mark)
                    return bytes
                }
                bytes.append(byte)
            }
        }

        static func domain<Input: Cursor.`Protocol`<Byte, Never>>(_ input: inout Input) -> [Byte] {
            var bytes: [Byte] = []
            var beforeLastPeriod = input.checkpoint
            while true {
                let mark = input.checkpoint
                guard let byte = input.next(), RFC_1123.Grammar.isDomainByte(byte) else {
                    input.seek(to: mark)
                    if bytes.last == ASCII.Code.period.byte {
                        bytes.removeLast()
                        input.seek(to: beforeLastPeriod)
                    }
                    return bytes
                }
                if byte == ASCII.Code.period.byte {
                    beforeLastPeriod = mark
                }
                bytes.append(byte)
            }
        }

        static func append<Buffer: RangeReplaceableCollection<Byte>>(_ string: String, into buffer: inout Buffer) {
            buffer.append(contentsOf: string.utf8.lazy.map(Byte.init(bitPattern:)))
        }
    }
#endif
