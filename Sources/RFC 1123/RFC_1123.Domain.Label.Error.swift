extension RFC_1123.Domain.Label {

    public enum Error: Swift.Error, Sendable, Equatable {

        case empty

        case tooLong(_ length: Int, label: String)

        case invalidCharacters(_ label: String, byte: Byte, reason: String)
    }
}

extension RFC_1123.Domain.Label.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .empty:
            return "Domain label cannot be empty"

        case .tooLong(let length, let label):
            return "Domain label '\(label)' is too long (\(length) bytes, maximum 63)"

        case .invalidCharacters(let label, let byte, let reason):
            return
                "Domain label '\(label)' has invalid byte 0x\(String(byte, radix: 16)): \(reason)"
        }
    }
}
