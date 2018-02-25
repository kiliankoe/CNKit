import Foundation
import MapKit

/// A building complex, possibly made up of more than one building.
public struct BuildingComplex: Codable, CustomStringConvertible {
    /// The building's abbreviation or ID, e.g. "APB".
    public let abbreviation: String
    /// The building's name, e.g. "Andreas-Pfitzmann-Bau"
    public let name: String
    /// The building's raw default level, usually the ground floor, e.g. "00".
    /// Use `.defaultLevel` instead for a more sensible interpretation.
    public let rawDefaultFloor: String?
    /// The building's default level, usually the ground floor, e.g. 0.
    public var defaultFloor: Int? {
        guard let floor = rawDefaultFloor else { return nil }
        return Int(fromFloorLevel: floor)
    }
    /// Basic accessibility information.
    public let accessibilityOverview: [String: String]?

    /// A list of entrances.
    public let entrances: [Entrance]
    /// A list of images.
    public let images: [String]?
    /// A list of actual building structures, should obviously be at least one.
    public let structures: [BuildingStructure]

    /// The list of images as URLs.
    public var imageURLs: [URL] {
        guard let images = images else { return [] }
        return images.flatMap { URL(cnPath: $0) }
    }

    let rawPoints: [[[String: Double]]]
    /// A list of coordinates that make up the building structure's outlines.
    public var points: [[CLLocationCoordinate2D]] {
        // x and y are switched
        return rawPoints.map { $0.map({ return CLLocationCoordinate2D(latitude: $0["y"]!, longitude: $0["x"]!) }) }
    }

    /// A rectangle encompassing the entire building complex.
    public var rect: MKMapRect {
        var mapRect = MKMapRectNull
        for structurePoints in points {
            for point in structurePoints {
                let mapPoint = MKMapPointForCoordinate(point)
                mapRect = MKMapRectUnion(mapRect, MKMapRectMake(mapPoint.x, mapPoint.y, 0, 0))
            }
        }
        return mapRect
    }

    /// A region showing an entire building complex with some space on the outside.
    public var region: MKCoordinateRegion {
        // Another option for this would be to use the rect directly and set the map's visible rect on
        // the other end, but adding UIEdgeInsets with values of 80.0 for every side. Doing this here
        // isn't necessarily better, but feels more contained. Not quite sure yet.

        var rect = self.rect
        rect.resize(800)
        return MKCoordinateRegionForMapRect(rect)
    }

    /// The geographical center of the entire building complex, great for rendering a name.
    public var center: CLLocationCoordinate2D {
        return region.center
    }

    /// Check if this BuildingComplex contains a given room.
    ///
    /// - Parameters:
    ///   - roomID: room identifier
    public func contains(roomWithID roomID: RoomID) -> Bool {
        return self.structures
            .contains { $0.id == roomID.buildingStructure }
    }

    private enum CodingKeys: String, CodingKey {
        case abbreviation = "krz"
        case name
        case rawDefaultFloor = "stdetage"
        case accessibilityOverview = "barfrei_info"
        case entrances = "eingänge"
        case images = "bilder"
        case structures = "teilgeb"
        case rawPoints = "punkte"
    }

    /// A building's abbreviation and name.
    public var description: String {
        return "\(abbreviation): \(name)"
    }
}

extension BuildingComplex {
    /// A single structure being a part of a building complex.
    public struct BuildingStructure: Codable, CustomStringConvertible {
        /// The structure's name.
        public let name: String
        /// Year the structure was constructed.
        public let constructionYear: String
        /// Is the structure landmarked?
        public let isLandmarked: Bool
        /// Identifier
        public let id: String
        /// Street address
        public let address: String
        /// Zipcode
        public let zipcode: String
        /// City
        public let city: String

        private enum CodingKeys: String, CodingKey {
            case name = "name"
            case constructionYear = "bauj"
            case isLandmarked = "denkm"
            case id = "gebnr"
            case address = "str"
            case zipcode = "plz"
            case city = "ort"
        }

        /// The structure's name.
        public var description: String {
            return name
        }
    }
}

extension BuildingComplex {
    /// An entrance to a building complex.
    public struct Entrance: Codable, CustomStringConvertible {
        /// Identifier
        public let id: Int
        /// An image showing the entrance.
        public let image: String?
        /// A short textual note regarding this entrance.
        public let note: String?
        /// Is the entrance wheelchair accessible?
        public let isAccessible: Bool?
        /// Does the entrance have steps?
        public let hasSteps: Bool?
        /// Does the entrance have a button to open it automatically?
        public let hasOpenButton: Bool?
        /// Is the entrance at ground level?
        public let isAtGroundLevel: Bool?
        /// Does the entrance have a small threshold?
        public let hasThresholdSmall: Bool?
        /// Does the entrance have a bell?
        public let hasBell: Bool?
        /// Does the entrance have a dedicated accessibility bell?
        public let hasAccessibilityBell: Bool?
        /// Does the entrance have big steps?
        public let hasStepsBig: Bool?
        /// Does the entrance have a ramp?
        public let hasRamp: Bool?
        let rawLat: Double?
        let rawLon: Double?

        /// The entrancen's image (if any) as a direct URL.
        public var imageURL: URL? {
            guard let image = image else {
                return nil
            }
            return URL(cnPath: image)
        }

        /// Location of the entrance.
        public var location: CLLocationCoordinate2D? {
            guard let lat = self.rawLat, let lng = self.rawLon else {
                return nil
            }
            return CLLocationCoordinate2D(latitude: lat, longitude: lng)
        }

        private enum CodingKeys: String, CodingKey {
            case id = "adrdoor"
            case image = "bildURL"
            case note = "bemerkung"
            case isAccessible = "barrierefrei"
            case hasSteps = "treppe"
            case hasOpenButton = "taster"
            case isAtGroundLevel = "ebenerdig"
            case hasThresholdSmall = "absatz_klein"
            case hasBell = "allgem_klingel"
            case hasAccessibilityBell = "beh_klingel"
            case hasStepsBig = "stufen_gross"
            case hasRamp = "rampe"
            case rawLat = "lat"
            case rawLon = "lon"
        }

        /// Entrance number
        public var description: String {
            return "Entrance #\(id)"
        }
    }
}

extension BuildingComplex: APIResource {
    typealias CollectionType = [BuildingComplex]
    static let expectedEncoding: String.Encoding = .isoLatin1

    struct RequestResource { }
    static func request(to resource: BuildingComplex.RequestResource) -> URLRequest {
        let url = URL(string: "m/json_gebaeude/all", relativeTo: Config.baseURL)!
        return URLRequest(url: url)
    }

    /// Fetch all building complexes
    ///
    /// - Parameters:
    ///   - session: session to use, defaults to `.shared`
    ///   - rawDataHandler: receives the raw data before being parsed
    ///   - completion: handler
    public static func fetch(session: URLSession = .shared,
                             rawDataHandler: ((Data) -> Void)? = nil,
                             completion: @escaping (Result<[BuildingComplex]>) -> Void) {
        BuildingComplex.fetch(resource: RequestResource(), session: session, rawDataHandler: rawDataHandler, completion: completion)
    }
}

extension BuildingComplex {
    /// Specific accessibility information used for showing accessibility badges.
    public struct AccessibilityInfo: Decodable {

        /// Does the building have any wheelchair accessible entrances?
        public let hasAccessibleEntrance: Ternary
        /// Does the building have an elevator?
        public let hasElevator: Ternary
        /// List of entrance identifiers that are wheelchair accessible.
        public let accessibleEntrances: [Int]
        /// Does the building have any accessible restrooms?
        public let hasAccessibleRestrooms: Ternary
        /// List of elevator door widths in cm.
        public let elevatorDoorWidths: [Int]

        private enum RootCodingKeys: String, CodingKey {
            case data = "accessibility"
        }

        private enum CodingKeys: String, CodingKey {
            case hasAccessibleEntrance = "disabledentrancepresent"
            case hasElevator = "elevator"
            case accessibleEntrances = "disabledentrances"
            case hasAccessibleRestrooms = "disabledwc"
            case elevatorDoorWidths = "elevatordoorwidth"
        }

        public init(from decoder: Decoder) throws {
            let accContainer = try decoder.container(keyedBy: RootCodingKeys.self)
            let container = try accContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)

            if let hasAccessibleEntrance = try? container.decode(String.self, forKey: .hasAccessibleEntrance) {
                self.hasAccessibleEntrance = Ternary(stringValue: hasAccessibleEntrance)
            } else {
                self.hasAccessibleEntrance = .nodata
            }

            if let hasElevator = try? container.decode(String.self, forKey: .hasElevator) {
                self.hasElevator = Ternary(stringValue: hasElevator)
            } else {
                self.hasElevator = .nodata
            }

            if let accessibleEntrances = try? container.decode([Int].self, forKey: .accessibleEntrances) {
                self.accessibleEntrances = accessibleEntrances
            } else {
                self.accessibleEntrances = []
            }

            if let hasAccessibleRestrooms = try? container.decode(String.self, forKey: .hasAccessibleRestrooms) {
                self.hasAccessibleRestrooms = Ternary(stringValue: hasAccessibleRestrooms)
            } else {
                self.hasAccessibleRestrooms = .nodata
            }

            if let elevatorDoorWidths = try? container.decode([Int].self, forKey: .elevatorDoorWidths) {
                self.elevatorDoorWidths = elevatorDoorWidths
            } else {
                self.elevatorDoorWidths = []
            }
        }
    }
}

extension BuildingComplex.AccessibilityInfo: APIResource {
    typealias CollectionType = BuildingComplex.AccessibilityInfo

    static let expectedEncoding: String.Encoding = .utf8

    struct RequestResource {
        let buildingID: String
    }

    static func request(to resource: BuildingComplex.AccessibilityInfo.RequestResource) throws -> URLRequest {
        let url = URL(string: "api/0.1/buildinginfo/\(resource.buildingID.urlQueryEscaped)?accessibility=true", relativeTo: Config.baseURL)!
        return URLRequest(url: url)
    }

    /// Fetch accessibility information for a given building.
    ///
    /// - Parameters:
    ///   - buildingID: building abbreviation, e.g. `APB`
    ///   - session: session to use, defaults to `.shared`
    ///   - completion: handler
    public static func fetch(forBuilding buildingID: String,
                             session: URLSession = .shared,
                             completion: @escaping (Result<BuildingComplex.AccessibilityInfo>) -> Void) {
        BuildingComplex.AccessibilityInfo.fetch(resource: BuildingComplex.AccessibilityInfo.RequestResource(buildingID: buildingID), session: session, completion: completion)
    }
}

extension BuildingComplex {
    /// Fetch accessibility information for this building.
    ///
    /// - Parameters:
    ///   - session: session to use, defaults to `.shared`
    ///   - completion: handler
    /// - Throws: possible error on constructing the request
    public func fetchAccessibilityInfo(session: URLSession = .shared,
                                              completion: @escaping (Result<BuildingComplex.AccessibilityInfo>) -> Void) {
            BuildingComplex.AccessibilityInfo.fetch(forBuilding: self.abbreviation, session: session, completion: completion)
    }
}
