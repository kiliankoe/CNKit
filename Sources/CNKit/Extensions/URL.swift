import Foundation

extension URL {
    init?(cn_path path: String) {
        if let url = URL(string: path, relativeTo: Config.baseURL) {
            self = url
        } else {
            return nil
        }
    }
}
