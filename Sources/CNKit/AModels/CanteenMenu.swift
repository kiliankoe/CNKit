import Foundation

public struct CanteenMenu: Decodable {
    public let menuName: String
    public let meals: [Meal]

    static let all = [
        "m13": "Alte Mensa",
        "nmen": "Zeltschlößchen",
        "mjoh": "Mensa Johannstadt",
        "mrei": "Mensa Reichenbachstraße",
        "pot": "BioMensa U-Boot",
        "web": "Mensa Blau",
        "bzw": "Mensa Siedepunkt",
        "ros": "Mensa TellerRandt",
        "gcub": "GrillCube",
    ]

    private enum CodingKeys: String, CodingKey {
        case menuName = "name"
        case meals = "diet"
    }
}

extension CanteenMenu {
    public struct Meal: Decodable {
        public let description: String
        public let prices: String?

        private enum CodingKeys: String, CodingKey {
            case description = "name"
            case prices
        }

        public init(from decoder: Decoder) throws {
            var container = try decoder.unkeyedContainer()
            self.description = try container.decode(String.self)
            let prices = try container.decode(String.self)
            if !prices.isEmpty {
                self.prices = prices
            } else {
                self.prices = nil
            }
        }
    }
}

extension CanteenMenu: APIResource {
    typealias CollectionType = CanteenMenu

    static var expectedEncoding: String.Encoding = .utf8

    struct RequestResource {
        let canteenID: String
    }

    static func request(to resource: CanteenMenu.RequestResource) throws -> URLRequest {
        guard let canteenID = resource.canteenID.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            throw Error.invalidQuery(reason: "failed to encode canteen id \(resource.canteenID)")
        }
        let url = URL(string: "/diet/\(canteenID)", relativeTo: Config.baseURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST" // (┛ò__ó)┛彡┻━┻
        return request
    }

    /// Fetch the menu for a given canteen.
    ///
    /// - Parameters:
    ///   - canteenID: the canteen's building abbreviation
    ///   - session: session to use, defaults to `.shared`
    ///   - completion: handler
    public static func fetch(forCanteen canteenID: String,
                             session: URLSession = .shared,
                             completion: @escaping (Result<CanteenMenu>) -> Void) {
        let resource = RequestResource(canteenID: canteenID)
        CanteenMenu.fetch(resource: resource, session: session, completion: completion)
    }
}
