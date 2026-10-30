#if Coder
    import ASCII
    import Byte

    extension RFC_1123 {

        enum Grammar {

            static func isLabelByte(_ byte: Byte) -> Bool {
                guard let code = try? ASCII.Code(byte) else { return false }
                return code.isLetter || code.isDigit || code == ASCII.Code.hyphen
            }

            static func isDomainByte(_ byte: Byte) -> Bool {
                guard let code = try? ASCII.Code(byte) else { return false }
                return code.isLetter || code.isDigit || code == ASCII.Code.hyphen || code == ASCII.Code.period
            }
        }
    }
#endif
