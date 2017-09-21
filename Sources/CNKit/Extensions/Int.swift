import Foundation

internal extension Int {
    var asFloorID: String {
        switch self {
        case 0...9:
            return "0\(self)"
        default:
            return "\(self)"
        }
    }
}
