import Foundation

internal extension Int {
    var floorLevel: String {
        switch self {
        case 0...9:
            return "0\(self)"
        default:
            return "\(self)"
        }
    }

    init?(fromFloorLevel level: String) {
        guard
            level != "--",
            let value = Int(level)
        else {
            return nil
        }
        self = value
    }
}

// is this sensible to have?
internal extension Optional where Wrapped == Int {
    var floorLevel: String {
        guard let value = self else {
            return "--"
        }
        return value.floorLevel
    }
}
