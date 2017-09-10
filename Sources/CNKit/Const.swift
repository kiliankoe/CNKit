import Foundation

enum Config {
    static let baseURL = URL(string: "https://navigator.tu-dresden.de/")!
}

extension URL {
    init?(cn_path path: String?) {
        guard
            let path = path,
            let escaped = path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: escaped, relativeTo: Config.baseURL)
        else {
            return nil
        }
        self = url
    }
}
