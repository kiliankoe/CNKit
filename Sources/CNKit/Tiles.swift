import Foundation

public enum Tiles {
    public static func mapURL(x: Int, y: Int, z: Int) -> URL {
        return URL(string: "/tileserver/\(z)/\(x)/\(y).png/nobase64", relativeTo: Config.baseURL)!
    }

    public static func floorplanURL(x: Int, y: Int, z: Int) -> URL {
        return URL(string: "/images/etplan_cache/APB00_\(z)/\(x)_\(y).png/nobase64", relativeTo: Config.baseURL)!
    }
}
