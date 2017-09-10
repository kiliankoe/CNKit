import Foundation

public struct Hash: Codable {
    public let hash: String
    public let encryption: Bool
}

extension Hash: APIResource {
    typealias CollectionType = Hash

    static var expectedEncoding = String.Encoding.utf8

    // RequestConfig serves no purpose here, but some kind of type has to be specified for every APIResource.
    struct RequestConfig { }
    typealias RequestResource = RequestConfig?

    static func request(to resource: RequestConfig? = nil) -> URLRequest {
        let url = URL(string: "m/json_gebaeude/hash", relativeTo: Config.baseURL)!
        return URLRequest(url: url)
    }

    /// Fetch the current data hash value.
    public static func fetch(session: URLSession = URLSession.shared,
                             completion: @escaping (Result<Hash>) -> Void) {
        Hash.fetch(to: nil, body: nil, session: session, completion: completion)
    }
}
