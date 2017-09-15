import Foundation
import MapKit

/// A building complex, possibly made up of more than one building.
public struct BuildingComplex: Codable, CustomStringConvertible {
    public let abbrev: String
    public let name: String
    public let defaultLevel: String?
    public let accessibilityOverview: [String: String]?

    public let entrances: [Entrance]
    public let images: [String]?
    public let structures: [BuildingStructure]

    public var imageURLs: [URL] {
        guard let images = images else { return [] }
        return images.flatMap { URL(cn_path: $0) }
    }

    let rawPoints: [[[String: Double]]]
    public var points: [[CLLocationCoordinate2D]] {
        // x and y are switched
        return rawPoints.map { $0.map({ return CLLocationCoordinate2D(latitude: $0["y"]!, longitude: $0["x"]!) }) }
    }

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

    public var region: MKCoordinateRegion {
        // Another option for this would be to use the rect directly and set the map's visible rect on
        // the other end, but adding UIEdgeInsets with values of 80.0 for every side. Doing this here
        // isn't necessarily better, but feels more contained. Not quite sure yet.

        var rect = self.rect
        rect.resize(800)
        return MKCoordinateRegionForMapRect(rect)
    }

    public var center: CLLocationCoordinate2D {
        return region.center
    }

    private enum CodingKeys: String, CodingKey {
        case abbrev = "krz"
        case name
        case defaultLevel = "stdetage"
        case accessibilityOverview = "barfrei_info"
        case entrances = "eingänge"
        case images = "bilder"
        case structures = "teilgeb"
        case rawPoints = "punkte"
    }

    public var description: String {
        return "\(abbrev): \(name)"
    }
}

extension BuildingComplex {
    /// A single structure being a part of a building complex, many buildings
    public struct BuildingStructure: Codable, CustomStringConvertible {
        public let name: String
        public let constructionYear: String
        public let isLandmarked: Bool
        public let id: String
        public let address: String
        public let zipcode: String
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

        public var description: String {
            return name
        }
    }
}

extension BuildingComplex {
    /// An entrance to a building complex.
    public struct Entrance: Codable, CustomStringConvertible {
        public let id: Int
        public let image: String?
        public let note: String?
        public let isAccessible: Bool?
        public let hasSteps: Bool?
        public let hasOpenButton: Bool?
        public let isAtGroundLevel: Bool?
        public let hasThresholdSmall: Bool?
        public let hasBell: Bool?
        public let hasAccessibilityBell: Bool?
        public let hasStepsBig: Bool?
        public let hasRamp: Bool?
        let rawLat: Double?
        let rawLon: Double?

        public var imageURL: URL? {
            return URL(cn_path: image)
        }

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

        public var description: String {
            return "Entrance #\(id)"
        }
    }
}

extension BuildingComplex: APIResource {
    typealias CollectionType = [BuildingComplex]
    static var expectedEncoding: String.Encoding = .isoLatin1

    struct RequestResource { }
    static func request(to resource: BuildingComplex.RequestResource) -> URLRequest {
        let url = URL(string: "m/json_gebaeude/all", relativeTo: Config.baseURL)!
        return URLRequest(url: url)
    }

    /// Fetch all building complexes
    ///
    /// - Parameters:
    ///   - session: session to use, defaults to `.shared`
    ///   - completion: handler
    public static func fetchAll(session: URLSession = .shared,
                                completion: @escaping (Result<[BuildingComplex]>) -> Void) {
        BuildingComplex.fetch(resource: RequestResource(), body: nil, session: session, completion: completion)
    }
}

extension BuildingComplex {
    public struct AccessibilityInfo: Decodable {

        public let hasDisabledEntrance: Trillian
        public let hasElevator: Trillian
        public let disabledEntrances: [Int]
        public let hasDisabledRestrooms: Trillian
        public let elevatorDoorWidths: [Int]


        private enum RootCodingKeys: String, CodingKey {
            case data = "accessibility"
        }

        private enum CodingKeys: String, CodingKey {
            case hasDisabledEntrance = "disabledentrancepresent"
            case hasElevator = "elevator"
            case disabledEntrances = "disabledentrances"
            case hasDisabledRestrooms = "disabledwc"
            case elevatorDoorWidths = "elevatordoorwidth"
        }

        public init(from decoder: Decoder) throws {
            let accContainer = try decoder.container(keyedBy: RootCodingKeys.self)
            let container = try accContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)

            if let hasDisabledEntrance = try? container.decode(String.self, forKey: .hasDisabledEntrance) {
                self.hasDisabledEntrance = Trillian(stringValue: hasDisabledEntrance)
            } else {
                self.hasDisabledEntrance = .nodata
            }

            if let hasElevator = try? container.decode(String.self, forKey: .hasElevator) {
                self.hasElevator = Trillian(stringValue: hasElevator)
            } else {
                self.hasElevator = .nodata
            }

            if let disabledEntrances = try? container.decode([Int].self, forKey: .disabledEntrances) {
                self.disabledEntrances = disabledEntrances
            } else {
                self.disabledEntrances = []
            }

            if let hasDisabledRestrooms = try? container.decode(String.self, forKey: .hasDisabledRestrooms) {
                self.hasDisabledRestrooms = Trillian(stringValue: hasDisabledRestrooms)
            } else {
                self.hasDisabledRestrooms = .nodata
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

    static var expectedEncoding = String.Encoding.utf8

    struct RequestResource {
        let buildingID: String
    }

    static func request(to resource: BuildingComplex.AccessibilityInfo.RequestResource) throws -> URLRequest {
        guard let buildingID = resource.buildingID.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw Error.invalidQuery(reason: "failed to encode building id \(resource.buildingID)")
        }
        let url = URL(string: "api/0.1/buildinginfo/\(buildingID)?accessibility=true", relativeTo: Config.baseURL)!
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
        BuildingComplex.AccessibilityInfo.fetch(resource: BuildingComplex.AccessibilityInfo.RequestResource(buildingID: buildingID), body: nil, session: session, completion: completion)
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
            BuildingComplex.AccessibilityInfo.fetch(forBuilding: self.abbrev, session: session, completion: completion)
    }
}
