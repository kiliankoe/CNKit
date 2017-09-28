import Foundation

/// Room Identifier, e.g. 351601.0420
public struct RoomID {
    /// Identifier of the building structure this room is located in.
    /// Use `BuildingComplex.contains(roomWithID:)` instead of manual lookup.
    public let buildingStructure: String
    /// Floor level string value, e.g. "-1", "00", etc.
    /// Use `.level` instead for a more sensible representation.
    public let rawLevel: String
    /// A room's actual identifier, not actually used anywhere, see `.fullID` instead.
    public let roomID: String

    /// Floor level
    public var level: Int? {
        return Int(fromFloorLevel: self.rawLevel)
    }

    /// The room's identifer, used by other endpoints and as a general identifier.
    public let fullID: String

    public init(withString value: String) {
        let components = value.split(separator: ".").map(String.init)
        self.buildingStructure = String(components[0].prefix(4))
        self.rawLevel = String(components[0].suffix(2))
        self.roomID = components[1]

        self.fullID = value
    }
}

extension RoomID: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String

    public init(stringLiteral value: RoomID.StringLiteralType) {
        self.init(withString: value)
    }
}
