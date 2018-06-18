import Foundation

/// Additional information to be accessed for a room.
public struct RoomInfo: Decodable {
    /// The room's name
    public let name: String
    /// The room's type
    public let type: RoomType
    /// Is routing available for this room?
    public let isRoutable: Bool

    /// Data for the room's accessibility badge.
    public let accessibilityBadge: AccessibilityBadge?
    /// Data for the room's digital doorplate.
    public let doorplate: Doorplate?

    private enum CodingKeys: String, CodingKey {
        case name
        case type
        case isRoutable = "routing"
        case accessibilityBadge = "accessibility"
        case doorplate
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.type = try container.decode(RoomType.self, forKey: .type)
        self.isRoutable = try container.decode(Bool.self, forKey: .isRoutable)

        if let accBadge = try? container.decode(AccessibilityBadge.self, forKey: .accessibilityBadge) {
            self.accessibilityBadge = accBadge
        } else {
            self.accessibilityBadge = nil
        }

        if let doorplate = try? container.decode(Doorplate.self, forKey: .doorplate) {
            self.doorplate = doorplate
        } else {
            self.doorplate = nil
        }
    }
}

extension RoomInfo {
    /// Detailed accessibility information.
    public struct AccessibilityBadge: Decodable {
        /// Is this room's door wheelchair accessible?
        public let doorIsAccessible: Ternary
        /// The entrance door's width in cm.
        public let doorwidth: Int
        /// Are possible steps marked?
        public let stepsAreMarked: Ternary
        /// Is a hearingloop microport available?
        public let hearingloopMicroport: Ternary
        /// Is an inductive hearingloop available?
        public let hearingloopInductive: Ternary
        /// Are wheelchair spaces available?
        public let wheelchairSpacesAvailable: Ternary
        /// How many wheelchair spaces are available?
        public let wheelchairSpacesCount: Int
        /// Is the lecturer zone wheelchair accessible?
        public let lecturerZoneIsAccessible: Ternary

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
    /// Digital doorplate information.
    public struct Doorplate: Decodable {
        /// List of people listed to be in this room.
        public let people: [Person]
        /// The chair this room belongs to.
        public let chair: String
        /// Possible further information regarding this room.
        public let text: String
        /// The department this room belongs to.
        public let department: String
        /// The faculty this room belongs to.
        public let faculty: String

        /// A room occupant.
        public struct Person {
            /// Name
            public let name: String
            /// Function
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

    static let expectedEncoding: String.Encoding = .utf8

    struct RequestResource {
        let roomID: String
    }

    static func request(to resource: RoomInfo.RequestResource) throws -> URLRequest {
        let url = URL(string: "api/0.1/roominfo/\(resource.roomID.urlQueryEscaped)?accessibility=true&doorplate=true",
                      relativeTo: Config.baseURL)!
        return URLRequest(url: url)
    }

    /// Fetch additional room information for a given room.
    ///
    /// - Parameters:
    ///   - roomID: a room's ID, e.g. `136101.0400`
    ///   - session: session to use, defaults to `.shared`
    ///   - completion: handler
    public static func fetch(forRoom roomID: String,
                             session: URLSession = .shared,
                             completion: @escaping (Result<RoomInfo>) -> Void) {
        let resource = RequestResource(roomID: roomID)
        RoomInfo.fetch(resource: resource, session: session, completion: completion)
    }
}

extension RoomInfo {
    /// Additional accessiblity information.
    public struct AccessibilityInfo: Decodable {
        /// List of categories with additional information.
        public let categories: [AccessibilityCategory]

        /// A category containing further accessiblity information.
        public struct AccessibilityCategory {
            /// Title
            public let title: String
            /// List of entries.
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

            self.categories = Set(dict.keys.compactMap { $0.components(separatedBy: "_").first })
                .map { AccessibilityCategory(title: $0, fullDict: dict) }
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

    static let expectedEncoding: String.Encoding = .isoLatin1

    struct RequestResource {
        let roomID: String
    }

    static func request(to resource: RoomInfo.AccessibilityInfo.RequestResource) throws -> URLRequest {
        let url = URL(string: "m/json_barriereinfos/raum/\(resource.roomID.urlQueryEscaped)",
                      relativeTo: Config.baseURL)!
        return URLRequest(url: url)
    }

    /// Fetch additional accessiblity information for a given room.
    ///
    /// - Parameters:
    ///   - roomID: a room's ID, e.g. `136101.0400`
    ///   - session: session to use, defaults to `.shared`
    ///   - completion: handler
    public static func fetch(forRoom roomID: String,
                             session: URLSession = .shared,
                             completion: @escaping (Result<RoomInfo.AccessibilityInfo>) -> Void) {
        let resource = RequestResource(roomID: roomID)
        RoomInfo.AccessibilityInfo.fetch(resource: resource, session: session, completion: completion)
    }
}
