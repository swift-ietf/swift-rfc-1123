# swift-rfc-1123

Use this package when you need a host name checked against RFC 1123, the rules that let a label start with a digit, as in `123.example.com`. Start from `RFC_1123.Domain`, or `RFC_1123.Domain.Label` for a single label. If you need DNS names under RFC 1035, use swift-rfc-1035. If you want a name valid under both, use `Domain` from swift-domain-standard. For internationalized names, use swift-rfc-5890. For `Codable`, add the `RFC 1123 Foundation Integration` product.

## Laws

- A label is 1 to 63 ASCII letters, digits and hyphens, and starts and ends with a letter or digit.
- A name has at most 127 labels and at most 255 bytes. Labels are separated by single dots, so a leading dot, a trailing dot or two dots in a row is an empty label and is refused. The absolute form `example.com.` is therefore not a valid name.
- The last label must start with a letter, so `example.123com` is refused. Digits may follow the letter, as in `example.com123`, and A-labels such as `xn--p1ai` are accepted.
- Names and labels keep the case they were written in for `RFC_1123.Domain.name`, printing and encoding. Equality and hashing ignore case.
- `RFC_1123.Domain.isSubdomain(of:)` is strict: a domain is not a subdomain of itself. Labels are compared ignoring case.
- `RFC_1123.Domain.parent()` drops the leftmost label and `RFC_1123.Domain.root()` keeps the last two. Both return nil for a single-label name.
- `RFC_1123.Domain.subdomain(_:)` takes its labels from the top level down, so the components `com`, `example`, `host` give `host.example.com`. `RFC_1123.Domain.addingSubdomain(_:)` takes them in written order and puts them in front.
- Converting between `RFC_1035.Domain` and `RFC_1123.Domain` goes through the text name and validates it again under the target's rules. An RFC 1035 name with a label such as `_dmarc` fails to convert.
- `RFC_1123.Domain.coder` reads the longest run of letters, digits, hyphens and dots, so it stops at a port colon or a space. A trailing dot is left unread. If the bytes read are not a valid name, it throws and leaves the input where it started.
- With `RFC 1123 Foundation Integration`, a domain or label encodes as its text and decodes from it. Text that is not valid fails to decode with a data-corrupted `DecodingError`.
