import Foundation

internal extension String {
    var urlPathEscaped: String? {
        return self.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
    }

    var urlQueryEscaped: String? {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
}
