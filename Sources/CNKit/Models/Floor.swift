import Foundation

public struct Floor: Decodable {
    let rawFloor: String
    public let maxX: Double
    public let maxY: Double
    public let rooms: [Room]

    public var floor: Int? {
        if self.rawFloor == "--" { return 0 }
        guard let intVal = Int(self.rawFloor) else { return nil }
        return intVal
    }

    private enum CodingKeys: String, CodingKey {
        case rawFloor = "etage"
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
        self.rawFloor = try container.decode(String.self, forKey: .rawFloor)
        self.maxX = try container.decode(Double.self, forKey: .maxX)
        self.maxY = try container.decode(Double.self, forKey: .maxY)

        // Opting not to use the API's colors, but hardcoded values instead.
        // Unless these are for something different and I understand what that might be...
        // See `RoomKind` below.

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
                room.kind = Room.Kind(value: roomType.type)
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
    public struct Room: Decodable {
        public let id: String
        public let name: String?
        public let nameLocation: (Double, Double)?
        public let points: [(Double, Double)]
        public let isInList: Bool

        public var kind: Kind

        public var rawColor: Int {
            return self.kind.color
        }

        private enum CodingKeys: String, CodingKey {
            case id
            case name
            case namex
            case namey
            case points = "punkte"
            case isInList = "list"
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(String.self, forKey: .id)
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

            if let inList = try container.decodeIfPresent(Bool.self, forKey: .isInList) {
                self.isInList = inList
            } else {
                self.isInList = false
            }

            // this is just a placeholder, the kind has to be set again after decoding all rooms
            self.kind = .other
        }
    }
}

extension Floor.Room {
    // List of types:
    // https://fusionforge.zih.tu-dresden.de/plugins/mediawiki/wiki/campusnavigator/index.php/Raumtypen
    // https://github.com/kiliankoe/campus-navigator/blob/master/CampusNavigator/CoreData/Room.m
    public enum Kind: Int {
        case stairwell = 11
        case elevator = 12
        case restroom = 13
        case accessibleRestroom = 14
        case babyChangingRoom = 15
        case library = 21
        case lecturehall = 22
        case seminarroom = 23
        case drawingroom = 24
        case restingroom = 26
        case coatroom = 27
        case room = 29
        case other = -1

        init(value: Int) {
            if let kind = Kind(rawValue: value) {
                self = kind
            } else {
                self = .other
            }
        }

        public var color: Int {
            switch self {
            case .stairwell: return 0xd4bfb4
            case .elevator: return 0xbd927b
            case .restroom,
                 .accessibleRestroom,
                 .babyChangingRoom: return 0xa3dbf0
            case .lecturehall: return 0xffa35c
            case .seminarroom: return 0xecf7aa
            case .coatroom: return 0xa09cbd
            case .room: return 0xf0f0f0
            default: return 0xffffff // white
            }
        }
    }
}

extension Floor: APIResource {
    typealias CollectionType = [Floor]

    static var expectedEncoding: String.Encoding = .isoLatin1

    struct RequestResource {
        let buildingID: String
    }

    static func request(to resource: Floor.RequestResource) throws -> URLRequest {
        guard let buildingID = resource.buildingID.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw Error.invalidQuery(reason: "failed to encode building id \(resource.buildingID)")
        }
        let url = URL(string: "m/json_etagen/\(buildingID)", relativeTo: Config.baseURL)!
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
        Floor.fetch(resource: resource, body: nil, session: session, completion: completion)
    }
}
