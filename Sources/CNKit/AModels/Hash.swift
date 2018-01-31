import Foundation

/// A hash used by the API to save data on requesting all building complexes.
public struct Hash: Codable {
    /// Current hash value.
    public let hash: String
    /// ¯\\_(ツ)\_/¯
    public let encryption: Bool
}

extension Hash: APIResource {
    typealias CollectionType = Hash

    static var expectedEncoding: String.Encoding = .isoLatin1

    struct RequestResource { }
    static func request(to resource: RequestResource) -> URLRequest {
        let url = URL(string: "m/json_gebaeude/hash", relativeTo: Config.baseURL)!
        return URLRequest(url: url)
    }

    /// Fetch the current data hash value.
    ///
    /// - Parameters:
    ///   - session: session to use, defaults to `.shared`
    ///   - completion: handler
    public static func fetch(session: URLSession = .shared,
                             completion: @escaping (Result<Hash>) -> Void) {
        Hash.fetch(resource: RequestResource(), session: session, completion: completion)
    }
}
