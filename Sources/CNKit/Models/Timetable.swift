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

extension Timetable.Day {
    public enum Weekday: Int, Decodable {
        case monday = 0
        case tuesday
        case wednesday
        case thursday
        case friday
    }
}
