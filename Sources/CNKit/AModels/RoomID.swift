import Foundation

public struct RoomID {
    public let buildingStructure: String
    public let rawFloor: String
    public let roomID: String

    public var floor: Int? {
        if self.rawFloor == "--" { return 0 }
        guard let intVal = Int(self.rawFloor) else { return nil }
        return intVal
    }

    public let rawValue: String

    public init(withString value: String) {
        let components = value.split(separator: ".").map(String.init)
        self.buildingStructure = String(components[0].prefix(4))
        self.rawFloor = String(components[0].suffix(2))
        self.roomID = components[1]

        self.rawValue = value
    }
}

extension RoomID: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String

    public init(stringLiteral value: RoomID.StringLiteralType) {
        self.init(withString: value)
    }
}
