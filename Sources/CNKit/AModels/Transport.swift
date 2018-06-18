import Foundation

/// A collection of departures at a given public transport stop.
public struct PublicTransport: Decodable {
    /// short description containing the stop name and current time.
    public let description: String
    /// list of departures.
    public let departures: [Departure]
    //    public let paths: [wat]
    /// associated color values.
    //    public let colors: [String: String]

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.description = try container.decode(String.self)
        self.departures = try container.decode([Departure].self)
        let _ = try container.decodeNil()
        //        self.colors = try container.decode([String: String].self)
    }
}

extension PublicTransport {
    /// A public transport departure, e.g. a bus, tram or similar.
    public struct Departure: Decodable {
        /// departure line, e.g. 3, 61, E9, etc.
        public let line: String
        /// the direction, e.g. "Bühlau", "Wilder Mann", etc.
        public let direction: String
        /// number of minutes before this departure leaves.
        public let eta: Int
        /// mode of transport
        public let mode: Mode?

        public enum Mode: String, Decodable {
            case tram = "t"
            case bus = "b"
        }

        public init(from decoder: Decoder) throws {
            var container = try decoder.unkeyedContainer()

            guard (container.count ?? 0) >= 3 else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(codingPath: [],
                                          debugDescription: "Departure expects at least 3 values"))
            }

            self.line = try container.decode(String.self)
            self.direction = try container.decode(String.self)

            let etaStr = try container.decode(String.self)
            if let eta = Int(etaStr) {
                self.eta = eta
            } else {
                self.eta = 0
            }

            self.mode = try container.decodeIfPresent(Mode.self)
        }
    }
}

extension PublicTransport: APIResource {
    typealias CollectionType = PublicTransport

    static let expectedEncoding: String.Encoding = .isoLatin1

    struct RequestResource {
        let stopName: String
    }

    static func request(to resource: RequestResource) throws -> URLRequest {
        let url = URL(string: "departures/\(resource.stopName.urlPathEscaped)", relativeTo: Config.baseURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST" // (╯°□°）╯︵ ┻━┻
        return request
    }

    /// Fetch a list of upcoming departures for a given stop.
    ///
    /// - Parameters:
    ///   - stop: stop name, e.g. `Münchner Platz`
    ///   - session: session to use, defaults to `.shared`
    ///   - completion: handler
    public static func fetch(forStop stop: String,
                             session: URLSession = .shared,
                             completion: @escaping (Result<PublicTransport>) -> Void) {
        let resource = RequestResource(stopName: stop)
        fetch(resource: resource, session: session, completion: completion)
    }
}
