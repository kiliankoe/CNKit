import Foundation
import MapKit

/// A building complex, possibly made up of more than one building.
public struct BuildingComplex {

}

extension BuildingComplex {
    public struct AccessibilityInfo: Decodable {

        public enum MaybeBool {
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

        public let hasDisabledEntrance: MaybeBool
        public let hasElevator: MaybeBool
        public let disabledEntrances: [Int]
        public let hasDisabledRestrooms: MaybeBool
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
                self.hasDisabledEntrance = MaybeBool(stringValue: hasDisabledEntrance)
            } else {
                self.hasDisabledEntrance = .nodata
            }

            if let hasElevator = try? container.decode(String.self, forKey: .hasElevator) {
                self.hasElevator = MaybeBool(stringValue: hasElevator)
            } else {
                self.hasElevator = .nodata
            }

            if let disabledEntrances = try? container.decode([Int].self, forKey: .disabledEntrances) {
                self.disabledEntrances = disabledEntrances
            } else {
                self.disabledEntrances = []
            }

            if let hasDisabledRestrooms = try? container.decode(String.self, forKey: .hasDisabledRestrooms) {
                self.hasDisabledRestrooms = MaybeBool(stringValue: hasDisabledRestrooms)
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

    static func request(to resource: BuildingComplex.AccessibilityInfo.RequestResource) -> URLRequest {
        // FIXME: This needs urlqueryallowed escapes and error handling
        let url = URL(string: "api/0.1/buildinginfo/\(resource.buildingID)?accessibility=true", relativeTo: Config.baseURL)!
        return URLRequest(url: url)
    }

    public static func fetch(forBuilding buildingID: String,
                             completion: @escaping (Result<BuildingComplex.AccessibilityInfo>) -> Void) {
        BuildingComplex.AccessibilityInfo.fetch(resource: BuildingComplex.AccessibilityInfo.RequestResource(buildingID: buildingID), body: nil, completion: completion)
    }
}
