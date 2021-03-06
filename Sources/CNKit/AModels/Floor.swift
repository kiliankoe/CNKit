import Foundation

/// A floor inside a building.
public struct Floor: Decodable {
    /// Floor level string value, e.g. "-1", "--", "00", etc.
    /// Use `.level` instead for a more sensible interpretation.
    public let rawLevel: String
    /// Maximum X coordinate.
    public let maxX: Double
    /// Maximum Y coordinate.
    public let maxY: Double
    /// All rooms on this floor.
    public let rooms: [Room]

    /// Floor level
    public var level: Int? {
        return Int(fromFloorLevel: self.rawLevel)
    }

    private enum CodingKeys: String, CodingKey {
        case rawLevel = "etage"
        case maxX
        case maxY
        case colors = "raumf"
        case types = "typen"
    }

    private enum TypeCodingKeys: String, CodingKey {
        case type = "typ"
        case rooms = "räume"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.rawLevel = try container.decode(String.self, forKey: .rawLevel)
        self.maxX = try container.decode(Double.self, forKey: .maxX)
        self.maxY = try container.decode(Double.self, forKey: .maxY)

        // Opting not to use the API's colors, but hardcoded values instead.
        // Unless these are for something different and I understand what that might be...

//         Convert a string in the format `1:#575757|2:#dbd8db...` to type `[Int:String]`.
//        let colorValues = try container.decode(String.self, forKey: .colors)
//            .split(separator: "|")
//            .map(String.init)
//            .flatMap { str -> (Int, String)? in
//                let values = str.split(separator: ":")
//                guard values.count == 2 else { return nil }
//                guard let roomID = Int(values[0]) else { return nil }
//                let hexColor = String(values[1])
//                return (roomID, hexColor)
//            }/
//
//        var colors = Dictionary<Int, String>()
//        for val in colorValues {
//            colors[val.0] = val.1
//        }

        var typesContainer = try container.nestedUnkeyedContainer(forKey: .types)

        // this can't be the normal way to go about this, can it?
        var roomTypes = [RoomTypeCollection]()
        while !typesContainer.isAtEnd {
            roomTypes.append(try typesContainer.decode(RoomTypeCollection.self))
        }

        self.rooms = roomTypes.flatMap { roomType in
            return roomType.rooms.map { room -> Room in
                var room = room
                room.type = RoomType(value: roomType.type)
                return room
            }
        }
    }
}

private extension Floor {
    struct RoomTypeCollection: Decodable {
        public let type: Int
        public let rooms: [Room]

        private enum CodingKeys: String, CodingKey {
            case type = "typ"
            case rooms = "räume"
        }
    }
}

extension Floor {
    /// A single room.
    public struct Room: Decodable {
        /// Identifier
        public let identifier: RoomID
        /// Name
        public let name: String?
        /// Preferred location for rendering the name.
        public let nameLocation: (Double, Double)?
        /// Points outlining the room.
        public let points: [(Double, Double)]
        /// Is this room a lecture hall?
        public let isLectureHall: Bool

        /// Type of the room
        public var type: RoomType

        /// Raw color value.
        public var rawColor: Int {
            return self.type.color
        }

        private enum CodingKeys: String, CodingKey {
            case identifier = "id"
            case name
            case namex
            case namey
            case points = "punkte"
            case isLectureHall = "list"
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let rawID = try container.decode(String.self, forKey: .identifier)
            self.identifier = RoomID(withString: rawID)
            self.name = try container.decodeIfPresent(String.self, forKey: .name)

            if
                let nameX = try container.decodeIfPresent(Double.self, forKey: .namex),
                let nameY = try container.decodeIfPresent(Double.self, forKey: .namey)
            {
                self.nameLocation = (nameX, nameY)
            } else {
                self.nameLocation = nil
            }

            let rawPoints = try container.decode([[String: Double]].self, forKey: .points)
            self.points = try rawPoints.map {
                guard let x = $0["x"], let y = $0["y"] else {
                    throw DecodingError.valueNotFound(Double.self, DecodingError.Context(codingPath: [CodingKeys.points], debugDescription: "Room point coordinates not found"))
                }
                return (x, y)
            }

            if let inList = try container.decodeIfPresent(Bool.self, forKey: .isLectureHall) {
                self.isLectureHall = inList
            } else {
                self.isLectureHall = false
            }

            // this is just a placeholder, the type has to be set again after decoding all rooms
            self.type = .other
        }
    }
}

extension Floor: APIResource {
    typealias CollectionType = [Floor]

    static let expectedEncoding: String.Encoding = .isoLatin1

    struct RequestResource {
        let buildingID: String
    }

    static func request(to resource: Floor.RequestResource) throws -> URLRequest {
        let url = URL(string: "m/json_etagen/\(resource.buildingID.urlQueryEscaped)", relativeTo: Config.baseURL)!
        return URLRequest(url: url)
    }

    /// Fetch the floorplan layout for a given building.
    ///
    /// - Parameters:
    ///   - buildingID: building abbreviation, e.g. `APB`
    ///   - session: session to use, defaults to `.shared`
    ///   - completion: handler
    public static func fetch(forBuilding buildingID: String,
                             session: URLSession = .shared,
                             completion: @escaping (Result<[Floor]>) -> Void) {
        let resource = Floor.RequestResource(buildingID: buildingID)
        Floor.fetch(resource: resource, session: session, completion: completion)
    }
}
