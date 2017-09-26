import Foundation

/// A list of search results.
public struct Search: Decodable {
    /// Text to help completing the user's input.
    public let autocomplete: String
    /// A list of buildings matching the search query.
    public let buildingResults: [SearchResult]
    /// A list of rooms matching the search query.
    public let roomResults: [SearchResult]

    // There's also `trenn`: Int, which shows where a divider line should be inserted (uninteresting here)
    // and `results_geo`: e.g. `[{"geocoords":[13.7453834, 51.0625425], "name":"Albertplatz"}, ...]`
    // which only applies when searching for route start- or endpoints, so also uninteresting here.
    // I'm also leaving away the second autocomplete field (`assist2`) and the flags for `moreBuildings`
    // and `moreRooms`. Just listing them all here for the sake of completeness.

    private enum CodingKeys: String, CodingKey {
        case autocomplete = "assist"
        case buildingResults = "results_geb"
        case roomResults = "results_raum"
    }
}

extension Search {
    /// A single search result.
    public struct SearchResult: Decodable {
        /// Title to display.
        public let title: String
        /// Campus Navigator resource.
        public let resource: Resource

        public init(from decoder: Decoder) throws {
            var container = try decoder.unkeyedContainer()

            // The search results sometime contain HTML styling info 🙄 Let's strip that.
            // Example result: `APB 3105 <span class='sml'>(APB/3105/P)</span>`
            let rawTitle = try container.decode(String.self)
            let titleRegex = try NSRegularExpression(pattern: "( <.*>)")
            self.title = titleRegex.stringByReplacingMatches(in: rawTitle, range: NSMakeRange(0, rawTitle.count), withTemplate: "")

            self.resource = try container.decode(Resource.self)
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
