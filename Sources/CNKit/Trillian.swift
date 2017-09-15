/// Either `true`, `false` or `nodata`. Got a better name for this? Please refactor :)
public enum Trillian {
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
}
