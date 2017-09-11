import Foundation

public struct Hash: Codable {
    public let hash: String
    public let encryption: Bool
}

extension Hash: APIResource {
    typealias CollectionType = Hash

    static var expectedEncoding = String.Encoding.utf8

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
        Hash.fetch(resource: RequestResource(), body: nil, session: session, completion: completion)
    }
}
