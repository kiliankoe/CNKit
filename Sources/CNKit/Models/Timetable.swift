import Foundation

public struct Timetable: Decodable {
    public let week1Name: String
    public let week1: [Day]

    public let week2Name: String
    public let week2: [Day]

    private enum CodingKeys: String, CodingKey {
        case week1Name = "woche1name"
        case week1 = "woche1"
        case week2Name = "woche2name"
        case week2 = "woche2"
    }
}

extension Timetable {
    public struct Day: Decodable {
        public let day: Weekday
        public let periods: [Period]

        public var slots: [String] {
            return [
                "7:30 - 9:00",
                "9:20 - 10:50",
                "11:10 - 12:40",
                "13:00 - 14:30",
                "14:50 - 16:20",
                "16:40 - 18:10",
                "18:30 - 20:00",
                "20:20 - 21:50",
            ]
        }

        private enum CodingKeys: String, CodingKey {
            case day = "tag"
            case periods = "stunden"
        }

        public enum Weekday: Int, Decodable {
            case monday = 0
            case tuesday
            case wednesday
            case thursday
            case friday
        }
    }
}

extension Timetable.Day {
    public struct Period: Decodable {
        public let period: Int
        public let course: String
        // TODO: Isn't there an optional lecturer field here?

        private enum CodingKeys: String, CodingKey {
            case period = "ds"
            case course = "fach"
        }
    }
}

extension Timetable: APIResource {
    typealias CollectionType = Timetable

    static var expectedEncoding: String.Encoding = .isoLatin1

    struct RequestResource {
        let roomID: String
    }

    static func request(to resource: Timetable.RequestResource) throws -> URLRequest {
        guard let roomID = resource.roomID.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw Error.invalidQuery(reason: "failed to encode room id \(resource.roomID)")
        }
        let url = URL(string: "m/json_belegplan/\(roomID)", relativeTo: Config.baseURL)!
        return URLRequest(url: url)
    }

    /// Fetch timetable for a given room.
    ///
    /// - Parameters:
    ///   - roomID: a room's ID, e.g. `136101.0400`
    ///   - session: session to use, defaults to `.shared`
    ///   - completion: handler
    public static func fetch(forRoom roomID: String,
                             session: URLSession = .shared,
                             completion: @escaping (Result<Timetable>) -> Void) {
        let resource = Timetable.RequestResource(roomID: roomID)
        Timetable.fetch(resource: resource, body: nil, session: session, completion: completion)
    }
}
