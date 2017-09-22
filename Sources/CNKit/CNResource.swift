import Foundation
import struct CoreLocation.CLLocationCoordinate2D

/// A specific Campus Navigator resource, e.g. a room, a building's lecture halls, etc.
/// This primarily maps to anything the webapp can display in a specific view.
public enum CNResource: Decodable {
    /// A coordinate on the map, e.g. https://navigator.tu-dresden.de/@13.732,51.02839999999999,15.z
    case coordinate(coord: CLLocationCoordinate2D, zoom: Int)
    /// A specific region on the map, e.g. https://navigator.tu-dresden.de/karten/dresden/geb/apb
    case map(region: String, building: String)
    /// A route, e.g. https://navigator.tu-dresden.de/routing/APB/WEB/foot,shortest/@13.741269714355468,51.02893981618553,15.z
    case route(origin: String, destination: String, mode: Route.Mode) // Include the coordinate info in the params here?
    /// A specific building, e.g. https://navigator.tu-dresden.de/gebaeude/apb
    case building(building: String)
    /// A specific building's accessibility information, e.g. https://navigator.tu-dresden.de/barrierefrei/biz
    case buildingAccessibility(building: String)
    /// A specific building's lecture hall listing, e.g. https://navigator.tu-dresden.de/hoersaele/apb
    case lectureHalls(building: String)
    /// A specific floor, e.g. https://navigator.tu-dresden.de/etplan/apb/00
    case floor(building: String, floor: String)
    /// A single room highlighted on a specific floor, e.g. https://navigator.tu-dresden.de/etplan/biz/02/raum/062102.0020
    case roomOnFloor(building: String, floor: String, room: String)
    /// A specific room, e.g. https://navigator.tu-dresden.de/raum/apb/00/542100.2310
    case room(building: String, floor: String, room: String)

    /// Create a CNResource from a given Campus Navigator URL.
    ///
    /// - Parameter url: url
    /// - Throws: Error.cnresourceURL with the URL if unable to parse
    /// - Warning: This only accepts valid CN URLs, not the search output. See [here](https://fusionforge.zih.tu-dresden.de/tracker/?aid=1976).
    public init(withURL url: URL) throws {
        self = try CNResource.parse(url: url, urlType: .actual)
    }

    /// - Warning: This only accepts search results, not actual CN URLs.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawURLString = try container.decode(String.self)
        guard let rawURL = URL(string: rawURLString.urlPathEscaped) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Failed to encode search URL fragment as URL"))
        }
        self = try CNResource.parse(url: rawURL, urlType: .search)
    }

    static func parse(url: URL, urlType: URLOrdering) throws -> CNResource {
        // Try and catch invalid URLs from correctly pointing to unexpected invalid resources.
        var components = url.pathComponents.filter {
            !$0.replacingOccurrences(of: "/", with: "")
               .isEmpty
        }

        // this gets special handling, see
        // https://fusionforge.zih.tu-dresden.de/tracker/?aid=1976
        if urlType == .search {
            // building URLs: `dresden/geb/apb`
            // room URLs: `apb/00/raum/542100.2230`

            switch components.count {
            case 3:
                return CNResource.map(region: components[0], building: components[2])
            case 4:
                return CNResource.room(building: components[0], floor: components[1], room: components[3])
            default:
                throw Error.cnresourceURL(url.absoluteString)
            }
        }

        if components.first?.contains("@") ?? false {
            // https://navigator.tu-dresden.de/@13.732,51.02839999999999,15.z
            components = components[0].split(separator: ",").map(String.init)
            guard components.count == 3 else { throw Error.cnresourceURL(url.absoluteString) }
            let (rawLat, rawLng, rawZoom) = (components[0].replacingOccurrences(of: "@", with: ""), components[1], components[2].replacingOccurrences(of: ".z", with: ""))
            guard let lat = Double(rawLat), let lng = Double(rawLng), let zoom = Int(rawZoom) else { throw Error.cnresourceURL(url.absoluteString) }
            return CNResource.coordinate(coord: CLLocationCoordinate2D(latitude: lat, longitude: lng), zoom: zoom)
        }

        let urlType = components.removeFirst()
        switch urlType {
        case "karten":
            // https://navigator.tu-dresden.de/karten/dresden/geb/apb
            guard components.count == 3 else { throw Error.cnresourceURL(url.absoluteString) }
            return CNResource.map(region: components[0], building: components[1])
        case "routing":
            // https://navigator.tu-dresden.de/routing/APB/WEB/foot,shortest/@13.741269714355468,51.02893981618553,15.z
            guard components.count == 4 else { throw Error.cnresourceURL(url.absoluteString) }
            let origin = components[0]
            let destination = components[1]
            let mode = Route.Mode(rawValue: components[2].split(separator: ",").map(String.init)[0]) ?? .foot
            return CNResource.route(origin: origin, destination: destination, mode: mode)
        case "gebaeude":
            // https://navigator.tu-dresden.de/gebaeude/apb
            guard components.count == 1 else { throw Error.cnresourceURL(url.absoluteString) }
            return CNResource.building(building: components[0])
        case "barrierefrei":
            // https://navigator.tu-dresden.de/barrierefrei/biz
            guard components.count == 1 else { throw Error.cnresourceURL(url.absoluteString) }
            return CNResource.buildingAccessibility(building: components[0])
        case "hoersaele":
            // https://navigator.tu-dresden.de/hoersaele/apb
            guard components.count == 1 else { throw Error.cnresourceURL(url.absoluteString) }
            return CNResource.lectureHalls(building: components[0])
        case "etplan":
            if components.count == 2 {
                // https://navigator.tu-dresden.de/etplan/apb/00
                return CNResource.floor(building: components[0], floor: components[1])
            } else if components.count == 4 {
                // https://navigator.tu-dresden.de/etplan/biz/02/raum/062102.0020
                return CNResource.roomOnFloor(building: components[0], floor: components[1], room: components[3])
            }
            throw Error.cnresourceURL(url.absoluteString)
        case "raum":
            // https://navigator.tu-dresden.de/raum/apb/00/542100.2310
            guard components.count == 3 else { throw Error.cnresourceURL(url.absoluteString) }
            return CNResource.room(building: components[0], floor: components[1], room: components[2])
        default:
            throw Error.cnresourceURL(url.absoluteString)
        }
    }

    /// This resource's building ID, if any.
    public var buildingID: String? {
        switch self {
        case .coordinate(coord: _, zoom: _): return nil
        case .map(region: _, building: let b): return b
        case .route(origin: _, destination: _, mode: _): return nil
        case .building(building: let b): return b
        case .buildingAccessibility(building: let b): return b
        case .lectureHalls(building: let b): return b
        case .floor(building: let b, floor: _): return b
        case .roomOnFloor(building: let b, floor: _, room: _): return b
        case .room(building: let b, floor: _, room: _): return b
        }
    }

    /// The canonical user-accessible URL pointing to this resource.
    public var url: URL? {
        var path = "/"
        switch self {
        case .coordinate(coord: let coord, zoom: let zoom):
            path += "@\(coord.latitude),\(coord.longitude),\(zoom).z"
        case .map(region: let region, building: let building):
            path += "karten/\(region.urlPathEscaped)/geb/\(building.urlPathEscaped)"
        case .route(origin: let origin, destination: let destination, mode: let mode):
            path += "routing/\(origin)/\(destination)/\(mode.rawValue),shortest"
        case .building(building: let building):
            path += "gebaeude/\(building.urlPathEscaped)"
        case .buildingAccessibility(building: let building):
            path += "barrierefrei/\(building.urlPathEscaped)"
        case .lectureHalls(building: let building):
            path += "hoersaele/\(building.urlPathEscaped)"
        case .floor(building: let building, floor: let floor):
            path += "etplan/\(building.urlPathEscaped)/\(floor.urlPathEscaped)"
        case .roomOnFloor(building: let building, floor: let floor, room: let room):
            path += "etplan/\(building.urlPathEscaped)/\(floor.urlPathEscaped)/raum/\(room.urlPathEscaped)"
        case .room(building: let building, floor: let floor, room: let room):
            path += "raum/\(building.urlPathEscaped)/\(floor.urlPathEscaped)/\(room.urlPathEscaped)"
        }
        return URL(string: path, relativeTo: Config.baseURL)
    }

    internal enum URLOrdering {
        case actual
        case search
    }
}

extension CNResource: Equatable {
    public static func ==(lhs: CNResource, rhs: CNResource) -> Bool {
        switch (lhs, rhs) {
        case (.coordinate(coord: let lhsCoord, zoom: let lhsZoom), .coordinate(coord: let rhsCoord, zoom: let rhsZoom)):
            return lhsCoord.latitude == rhsCoord.latitude && lhsCoord.longitude == rhsCoord.longitude && lhsZoom == rhsZoom
        case (.map(region: let lhsRegion, building: let lhsBuilding), .map(region: let rhsRegion, building: let rhsBuilding)):
            return lhsRegion == rhsRegion && lhsBuilding == rhsBuilding
        case (.route(origin: let lhsOrigin, destination: let lhsDestination, mode: let lhsMode), .route(origin: let rhsOrigin, destination: let rhsDestination, mode: let rhsMode)):
            return lhsOrigin == rhsOrigin && lhsDestination == rhsDestination && lhsMode == rhsMode
        case (.building(building: let lhsBuilding), .building(building: let rhsBuilding)):
            return lhsBuilding == rhsBuilding
        case (.buildingAccessibility(building: let lhsBuilding), .buildingAccessibility(building: let rhsBuilding)):
            return lhsBuilding == rhsBuilding
        case (.lectureHalls(building: let lhsBuilding), .lectureHalls(building: let rhsBuilding)):
            return lhsBuilding == rhsBuilding
        case (.floor(building: let lhsBuilding, floor: let lhsFloor), .floor(building: let rhsBuilding, floor: let rhsFloor)):
            return lhsBuilding == rhsBuilding && lhsFloor == rhsFloor
        case (.roomOnFloor(building: let lhsBuilding, floor: let lhsFloor, room: let lhsRoom), .roomOnFloor(building: let rhsBuilding, floor: let rhsFloor, room: let rhsRoom)):
            return lhsBuilding == rhsBuilding && lhsFloor == rhsFloor && lhsRoom == rhsRoom
        case (.room(building: let lhsBuilding, floor: let lhsFloor, room: let lhsRoom), .room(building: let rhsBuilding, floor: let rhsFloor, room: let rhsRoom)):
            return lhsBuilding == rhsBuilding && lhsFloor == rhsFloor && lhsRoom == rhsRoom
        default:
            return false
        }
    }
}
