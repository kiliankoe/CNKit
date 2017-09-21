import Foundation

internal extension URL {
    init?(cnPath path: String) {
        if let url = URL(string: path, relativeTo: Config.baseURL) {
            self = url
        } else {
            return nil
        }
    }
}
