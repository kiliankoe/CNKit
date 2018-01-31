/// Either `true`, `false` or `nodata`. Got a better name for this? Please refactor :)
public enum Ternary: Decodable {
    case `true`
    case `false`
    case nodata

    public init(boolValue: Bool) {
        self = boolValue ? .true : .false
    }

    public init(stringValue: String) {
        switch stringValue.lowercased() {
        case "true": self = .true
        case "false": self = .false
        default: self = .nodata
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self.init(stringValue: rawValue)
    }
}
