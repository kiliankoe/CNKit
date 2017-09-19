import Foundation

public struct RoomInfo: Decodable {
    public let name: String
    public let type: RoomType
    public let isRoutable: Bool

    public let accessibilityBadge: AccessibilityBadge?
    public let doorplate: Doorplate?

    private enum CodingKeys: String, CodingKey {
        case name
        case type
        case isRoutable = "routing"
        case accessibilityBadge = "accessibility"
        case doorplate
    }
}

extension RoomInfo {
    public struct AccessibilityBadge: Decodable {
        public let doorIsAccessible: Trillian
        public let doorwidth: Int
        public let stepsAreMarked: Trillian
        public let hearingloopMicroport: Trillian
        public let hearingloopInductive: Trillian
        public let wheelchairSpacesAvailable: Trillian
        public let wheelchairSpacesCount: Int
        public let lecturerZoneIsAccessible: Trillian

        private enum CodingKeys: String, CodingKey {
            case doorIsAccessible = "door"
            case doorwidth
            case stepsAreMarked = "markedsteps"
            case hearingloopMicroport = "hearingloop_microport"
            case hearingloopInductive = "hearingloop_inductive"
            case wheelchairSpacesAvailable = "wheelchairspace_present"
            case wheelchairSpacesCount = "wheelchairspaces"
            case lecturerZoneIsAccessible = "lecturer"
        }
    }
}

extension RoomInfo {
    public struct Doorplate: Decodable {
        public let people: [Person]
        public let chair: String
        public let text: String
        public let department: String
        public let faculty: String

        public struct Person {
            public let name: String
            public let function: String
        }

        private enum CodingKeys: String, CodingKey {
            case names
            case functions
            case chair
            case text = "textarea"
            case department
            case faculty
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            let names = try container.decode([String].self, forKey: .names)
            let functions = try container.decode([String].self, forKey: .functions)
            if names.count != functions.count {
                print("Number of names and functions for this doorplate do not correlate directly.")
            }
            self.people = zip(names, functions)
                .filter { !$0.0.isEmpty && !$0.1.isEmpty }
                .map(Person.init)

            self.chair = try container.decode(String.self, forKey: .chair)
            self.text = try container.decode(String.self, forKey: .text)
                .replacingOccurrences(of: "\\n", with: "\n")
            self.department = try container.decode(String.self, forKey: .department)
            self.faculty = try container.decode(String.self, forKey: .faculty)
        }
    }
}

extension RoomInfo: APIResource {
    typealias CollectionType = RoomInfo

    static var expectedEncoding: String.Encoding = .utf8

    struct RequestResource {
        let roomID: String
    }

    static func request(to resource: RoomInfo.RequestResource) throws -> URLRequest {
        let url = URL(string: "api/0.1/roominfo/\(resource.roomID.urlQueryEscaped)?accessibility=true&doorplate=true", relativeTo: Config.baseURL)!
        return URLRequest(url: url)
    }

    public static func fetch(forRoom roomID: String,
                             session: URLSession = .shared,
                             completion: @escaping (Result<RoomInfo>) -> Void) {
        let resource = RequestResource(roomID: roomID)
        RoomInfo.fetch(resource: resource, session: session, completion: completion)
    }
}

extension RoomInfo {
    public struct AccessibilityInfo: Decodable {
        public let categories: [AccessibilityCategory]

        public struct AccessibilityCategory {
            public let title: String
            public let entries: [(String, String)]

            init(title: String, fullDict: [String: String]) {
                self.title = title.capitalized
                var entries: [(String, String)] = []
                for (key, value) in fullDict {
                    if key.hasPrefix(title) {
                        let topic = key.components(separatedBy: "_").dropFirst().joined(separator: " ").capitalized
                        entries.append((topic, value.capitalized))
                    }
                }
                self.entries = entries
            }
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let dict = try container.decode([String: StringOrInt].self)
                                    .mapValues { $0.stringValue }

            self.categories = Set(dict.keys.flatMap { $0.components(separatedBy: "_").first }).map { AccessibilityCategory(title: $0, fullDict: dict) }
        }

        /// This is a stupid workaround...
        struct StringOrInt: Decodable {
            let stringValue: String

            public init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                if let intValue = try? container.decode(Int.self) {
                    self.stringValue = String(intValue)
                } else {
                    self.stringValue = try container.decode(String.self)
                }
            }
        }
    }
}

extension RoomInfo.AccessibilityInfo: APIResource {
    typealias CollectionType = RoomInfo.AccessibilityInfo

    static var expectedEncoding: String.Encoding = .isoLatin1

    struct RequestResource {
        let roomID: String
    }

    static func request(to resource: RoomInfo.AccessibilityInfo.RequestResource) throws -> URLRequest {
        let url = URL(string: "m/json_barriereinfos/raum/\(resource.roomID.urlQueryEscaped)", relativeTo: Config.baseURL)!
        return URLRequest(url: url)
    }

    public static func fetch(forRoom roomID: String,
                             session: URLSession = .shared,
                             completion: @escaping (Result<RoomInfo.AccessibilityInfo>) -> Void) {
        let resource = RequestResource(roomID: roomID)
        RoomInfo.AccessibilityInfo.fetch(resource: resource, session: session, completion: completion)
    }
}
