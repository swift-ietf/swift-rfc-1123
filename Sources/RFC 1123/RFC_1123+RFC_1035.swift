public import RFC_1035

extension RFC_1035.Domain {
    public init(_ domain: RFC_1123.Domain) throws(RFC_1035.Domain.Error) {
        try self.init(domain.name)
    }
}

extension RFC_1123.Domain {

    public init(_ domain: RFC_1035.Domain) throws(Error) {
        try self.init(domain.name)
    }
}
