import Foundation

/// A Room's timetable, when is what kind of lesson.
public struct Timetable: Decodable, ResourceDecodable {
    /// Name and date for the current first week.
    public let week1Name: String
    /// List of the first week's days.
    public let week1: [Day]

    /// Name and date for the current second week.
    public let week2Name: String
    /// List of the second week's days.
    public let week2: [Day]

    var requestResource: RequestResource? = nil
    public var resource: CNResource? {
        guard let requestResource = self.requestResource else { return nil }
        return CNResource.room(building: "APB", floor: "00", room: requestResource.roomID)
    }

    private enum CodingKeys: String, CodingKey {
        case week1Name = "woche1name"
        case week1 = "woche1"
        case week2Name = "woche2name"
        case week2 = "woche2"
    }
}

extension Timetable {
    /// A single day.
    public struct Day: Decodable {
        /// Weekday
        public let day: Weekday
        /// List of courses
        public let courses: [Course]

        /// List of all possible timeslots.
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
            case courses = "stunden"
        }

        /// Weekday
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
    /// A single course.
    public struct Course: Decodable {
        /// Timeslot
        public let timeslot: Int
        /// Name
        public let name: String
        // TODO: Isn't there an optional lecturer field here?

        private enum CodingKeys: String, CodingKey {
            case timeslot = "ds"
            case name = "fach"
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
        let url = URL(string: "m/json_belegplan/\(resource.roomID.urlQueryEscaped)", relativeTo: Config.baseURL)!
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
        Timetable.fetch(resource: resource, session: session, completion: completion)
    }
}
