import Foundation

/// Generate valid URLs for both supported tileservers.
public enum Tiles {
    /// Generate a URL for the base map tileserver.
    ///
    /// - Parameters:
    ///   - x: x coordinate
    ///   - y: y coordinate
    ///   - z: z coordinate (zoom level)
    /// - Returns: URL for the specified tile.
    public static func mapURL(x: Int, y: Int, z: Int) -> URL {
        return URL(string: "/tileserver/\(z)/\(x)/\(y).png/nobase64", relativeTo: Config.baseURL)!
    }

    /// Generate a URL for the floorplan tileserver.
    ///
    /// - Parameters:
    ///   - building: building abbreviation
    ///   - floor: floor level
    ///   - x: x coordinate
    ///   - y: y coordinate
    ///   - z: z coordinate (zoom level)
    /// - Returns: URL for the specified tile.
    public static func floorplanURL(building: String, floor: Int, x: Int, y: Int, z: Zoomlevel) -> URL {
        let buildingID = building.uppercased().urlPathEscaped
        return URL(string: "/images/etplan_cache/\(buildingID)\(floor.floorLevel)_\(z.rawValue)/\(x)_\(y).png/nobase64",
                   relativeTo: Config.baseURL)!
    }
}

/// Position and URL for a floorplan tile image.
public struct FloorplanTile {
    public let xPos: Int
    public let yPos: Int
    public let url: URL
}

extension Tiles {
    public enum Zoomlevel: Int {
        case one = 1
        case two = 2
        case four = 4
        case eight = 8
    }

    /// Fetch all URLs for images making up the floorplan for a given building, floor and zoomlevel.
    ///
    /// Completion handler is explicitly called on main thread.
    ///
    /// - Parameters:
    ///   - building: building
    ///   - floor: floor
    ///   - zoomLevel: zoomlevel
    ///   - completion: handler
    /// - Warning: This triggers a whole bunch of HEAD requests, especially for closer zoomlevels.
    public static func allFloorplanTiles(forBuilding building: String,
                                         floor: Int,
                                         zoomLevel: Zoomlevel,
                                         completion: @escaping ([FloorplanTile]) -> Void) {
        let queue = DispatchQueue(label: "de.tu-dresden.navigator.CNKit", qos: .background)

        queue.async {
            let yVals = Array(0..<zoomLevel.rawValue)
            let xVals = Array(0..<zoomLevel.rawValue * 6) // Does 6 here really cover everything for all buildings?

            let tileCandidates = yVals.flatMap { y -> [FloorplanTile] in
                return xVals.map { x in
                    let url = Tiles.floorplanURL(building: building, floor: floor, x: x, y: y, z: zoomLevel)
                    return FloorplanTile(xPos: x, yPos: y, url: url)
                }
            }

            let tiles = tileCandidates
                .filter { $0.url.pointsToExistingResource }

            DispatchQueue.main.async {
                completion(tiles)
            }
        }
    }
}

