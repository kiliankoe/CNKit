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
    public static func floorplanURL(building: String, floor: Int, x: Int, y: Int, z: Int) -> URL {
        let buildingID = building.uppercased().urlPathEscaped
        return URL(string: "/images/etplan_cache/\(buildingID)\(floor.asFloorID)_\(z)/\(x)_\(y).png/nobase64", relativeTo: Config.baseURL)!
    }
}
