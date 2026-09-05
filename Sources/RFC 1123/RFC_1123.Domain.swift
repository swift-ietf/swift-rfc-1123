public import Byte
import ASCII
import Byte_Standard_Library_Integration

extension RFC_1123 {

    public struct Domain: Sendable {

        public let rawValue: String

        package let labels: [Domain.Label]

        init(
            __unchecked: Void,
            rawValue: String,
            labels: [Domain.Label]
        ) {
            self.rawValue = rawValue
            self.labels = labels
        }
    }
}

extension RFC_1123.Domain: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue.lowercased())
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue.lowercased() == rhs.rawValue.lowercased()
    }

    public static func == (lhs: Self, rhs: String) -> Bool {
        lhs.rawValue.lowercased() == rhs.lowercased()
    }
}

extension RFC_1123.Domain: CustomStringConvertible {

    public var description: String {
        rawValue
    }
}

extension RFC_1123.Domain {

    public init(_ string: some StringProtocol) throws(Error) {
        try self.init(ascii: string.utf8.map(Byte.init(bitPattern:)))
    }

    public init<Bytes: Swift.Collection>(ascii bytes: Bytes) throws(Error)
    where Bytes.Element == Byte {
        guard !bytes.isEmpty else {
            throw Error.empty
        }

        let length = bytes.count
        guard length <= Limits.maxLength else {
            throw Error.tooLong(length)
        }

        var labelSlices: [Bytes.SubSequence] = []
        var currentStart = bytes.startIndex
        var i = currentStart

        while i != bytes.endIndex {

            if bytes[i] == ASCII.Code.period.byte {

                labelSlices.append(bytes[currentStart..<i])
                currentStart = bytes.index(after: i)
            }
            i = bytes.index(after: i)
        }

        labelSlices.append(bytes[currentStart..<bytes.endIndex])

        guard labelSlices.count <= Limits.maxLabels else {
            throw Error.tooManyLabels
        }

        var labels: [Label] = []
        labels.reserveCapacity(labelSlices.count)

        for slice in labelSlices {
            do throws(Label.Error) {
                labels.append(try Label(ascii: slice))
            } catch {
                throw Error.invalidLabel(error)
            }
        }

        if let tld = labels.last {
            guard let first = tld.rawValue.utf8.first else {
                throw Error.invalidTLD(tld.rawValue)
            }

            let firstIsLetter: Bool
            do throws(ASCII.Code.Error) {
                firstIsLetter = try ASCII.Code(Byte(bitPattern: first)).isLetter
            } catch {
                firstIsLetter = false
            }

            guard firstIsLetter else {
                throw Error.invalidTLD(tld.rawValue)
            }
        }

        let rawValue = String(decoding: bytes, as: UTF8.self)
        self.init(__unchecked: (), rawValue: rawValue, labels: labels)
    }
}

extension RFC_1123.Domain {

    public var name: String {
        rawValue
    }

    public var tld: Label? {
        labels.last
    }

    public var sld: Label? {
        labels.dropLast().last
    }
}

extension RFC_1123.Domain {

    public func isSubdomain(of parent: RFC_1123.Domain) -> Bool {
        guard labels.count > parent.labels.count else { return false }
        return labels.suffix(parent.labels.count) == parent.labels
    }

    public func addingSubdomain(_ components: [String]) throws(Error) -> RFC_1123.Domain {
        var newLabels: [Label] = []
        for component in components {
            do throws(Label.Error) {
                newLabels.append(try Label(ascii: component.utf8.map(Byte.init(bitPattern:))))
            } catch {
                throw Error.invalidLabel(error)
            }
        }

        let allLabels = newLabels + labels
        guard allLabels.count <= Limits.maxLabels else {
            throw Error.tooManyLabels
        }

        let newName = (components + labels.map(\.rawValue)).joined(separator: ".")
        guard newName.count <= Limits.maxLength else {
            throw Error.tooLong(newName.count)
        }

        return RFC_1123.Domain(__unchecked: (), rawValue: newName, labels: allLabels)
    }

    public func addingSubdomain(_ components: String...) throws(Error) -> RFC_1123.Domain {
        try self.addingSubdomain(components)
    }

    public func parent() -> RFC_1123.Domain? {
        guard labels.count > 1 else { return nil }
        let parentLabels = Array(labels.dropFirst())
        let parentName = parentLabels.map(\.rawValue).joined(separator: ".")
        return RFC_1123.Domain(__unchecked: (), rawValue: parentName, labels: parentLabels)
    }

    public func root() -> RFC_1123.Domain? {
        guard labels.count >= 2 else { return nil }
        let rootLabels = Array(labels.suffix(2))
        let rootName = rootLabels.map(\.rawValue).joined(separator: ".")
        return RFC_1123.Domain(__unchecked: (), rawValue: rootName, labels: rootLabels)
    }
}

extension RFC_1123.Domain {

    public init(labels: [Label]) throws(Error) {
        guard !labels.isEmpty else {
            throw Error.empty
        }

        guard labels.count <= Limits.maxLabels else {
            throw Error.tooManyLabels
        }

        let name = labels.map(\.rawValue).joined(separator: ".")
        guard name.count <= Limits.maxLength else {
            throw Error.tooLong(name.count)
        }

        if let tld = labels.last {
            guard let first = tld.rawValue.utf8.first else {
                throw Error.invalidTLD(tld.rawValue)
            }

            let firstIsLetter: Bool
            do throws(ASCII.Code.Error) {
                firstIsLetter = try ASCII.Code(Byte(bitPattern: first)).isLetter
            } catch {
                firstIsLetter = false
            }

            guard firstIsLetter else {
                throw Error.invalidTLD(tld.rawValue)
            }
        }

        self.init(__unchecked: (), rawValue: name, labels: labels)
    }

    public static func root(_ sld: String, _ tld: String) throws(Error) -> RFC_1123.Domain {
        let sldLabel: Label
        let tldLabel: Label
        do throws(Label.Error) {
            sldLabel = try Label(sld)
        } catch {
            throw Error.invalidLabel(error)
        }
        do throws(Label.Error) {
            tldLabel = try Label(tld)
        } catch {
            throw Error.invalidLabel(error)
        }
        return try RFC_1123.Domain(labels: [sldLabel, tldLabel])
    }

    public static func subdomain(_ components: String...) throws(Error) -> RFC_1123.Domain {
        guard !components.isEmpty else {
            throw Error.empty
        }

        var labels: [Label] = []
        for label in components.reversed() {
            do throws(Label.Error) {
                labels.append(try Label(label))
            } catch {
                throw Error.invalidLabel(error)
            }
        }

        return try RFC_1123.Domain(labels: labels)
    }
}
