import Foundation

public struct Search: Decodable {
    public let autocomplete: String
    public let buildingResults: [SearchResult]
    public let roomResults: [SearchResult]

    // There's also `trenn`: Int, which shows where a divider line should be inserted (uninteresting here)
    // and `results_geo`: e.g.
    // [{"geocoords":[13.7453834, 51.0625425], "name":"Albertplatz"}, ...]
    // which only applies when search for route start- or endpoints, so also uninteresting here.
    // I'm also leaving away the second autocomplete field (`assist2`) and the flags for `moreBuildings`
    // and `moreRooms`. Just listing for the sake of completeness.

    private enum CodingKeys: String, CodingKey {
        case autocomplete = "assist"
        case buildingResults = "results_geb"
        case roomResults = "results_raum"
    }
}

extension Search {
    public struct SearchResult: Decodable {
        public let title: String

        // TODO: This should possibly be a URL instead, or maybe the parsed params to directly pass into deeplinking?
        public let resource: URL

        public init(from decoder: Decoder) throws {
            var container = try decoder.unkeyedContainer()
            self.title = try container.decode(String.self)
            guard let resourceURL = URL(string: try container.decode(String.self), relativeTo: Config.baseURL) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "resource URL was malformed"))
            }
            self.resource = resourceURL
        }
    }
}

extension Search: APIResource {
    typealias CollectionType = Search

    static var expectedEncoding: String.Encoding = .utf8

    struct RequestResource {
        let query: String
    }

    static func request(to resource: Search.RequestResource) throws -> URLRequest {
        let url = URL(string: "search", relativeTo: Config.baseURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setBody(["query": resource.query])
        return request
    }

    /// Search for buildings and rooms with a given query.
    ///
    /// - Parameters:
    ///   - query: query
    ///   - session: session to use, defaults to `.shared`
    ///   - completion: handler
    public static func query(_ query: String,
                             session: URLSession = .shared,
                             completion: @escaping (Result<Search>) -> Void) {
        let resource = RequestResource(query: query)
        Search.fetch(resource: resource, session: session, completion: completion)
    }
}
