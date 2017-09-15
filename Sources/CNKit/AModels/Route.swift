import Foundation
import struct CoreLocation.CLLocationCoordinate2D

public struct Route: Decodable {
    public let length: Double
    public let duration: Double
    public let coords: [CLLocationCoordinate2D]
    public let instructions: [Instruction]

    private enum CodingKeys: String, CodingKey {
        case length = "route_length"
        case duration = "route_time"
        case instructions
        case coords
    }

    private enum InstructionsCodingKeys: String, CodingKey {
        case distances
        case indications
        case durations = "mins"
        case descriptions
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.length = try container.decode(Double.self, forKey: .length)
        self.duration = try container.decode(Double.self, forKey: .duration)

        let rawCoords = try container.decode([Double].self, forKey: .coords)
        guard rawCoords.count % 2 == 0 else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [CodingKeys.coords], debugDescription: "odd number of coords received, has to be even"))
        }
        let lats = rawCoords.enumerated().filter { $0.offset % 2 == 0 }.map { $1 }
        let lngs = rawCoords.enumerated().filter { $0.offset % 2 != 0 }.map { $1 }
        self.coords = zip(lats, lngs).map { CLLocationCoordinate2D(latitude: $0.0, longitude: $0.1) }

        let instructionsContainer = try container.nestedContainer(keyedBy: InstructionsCodingKeys.self, forKey: .instructions)

        let distances = try instructionsContainer.decode([Double].self, forKey: .distances)
        let indications = try instructionsContainer.decode([Int].self, forKey: .indications)
        let durations = try instructionsContainer.decode([Int].self, forKey: .durations)
        let descriptions = try instructionsContainer.decode([String].self, forKey: .descriptions)

        let instructions = zip(zip(distances, indications), zip(durations, descriptions)).map { arg -> Instruction in
            let (arg0, arg1) = arg
            let (distance, rawIndication) = arg0
            let (duration, description) = arg1

            let indication = Instruction.Indication(rawValue: rawIndication)!
            return Instruction(distance: distance, indication: indication, duration: duration, description: description)
        }

        self.instructions = instructions
    }
}

extension Route {
    public struct Instruction {
        public let distance: Double
        public let indication: Indication
        public let duration: Int
        public let description: String

        public enum Indication: Int {
            case sharpLeft = -3
            case left = -2
            case lightLeft = -1

            case `continue` = 0

            case lightRight = 1
            case right = 2
            case sharpRight = 3

            case intermediate = 5
            case roundabout = 6

            case destinationReached = 4
        }
    }
}

extension Route {
    public enum Mode: String {
        case foot
        case bike
        case wheelchair
        case car
    }
}

extension Route: APIResource {
    typealias CollectionType = Route

    static var expectedEncoding: String.Encoding = .utf8

    struct RequestResource {
        let origin: CLLocationCoordinate2D
        let destination: CLLocationCoordinate2D
        let mode: Route.Mode
        let locale: Locale
    }

    static func request(to resource: Route.RequestResource) throws -> URLRequest {
        let (olat, olng) = (resource.origin.latitude, resource.origin.longitude)
        let (dlat, dlng) = (resource.destination.latitude, resource.destination.longitude)
        let url = URL(string: "routingservice/\(olat),\(olng)/\(dlat),\(dlng)/\(resource.mode.rawValue)/geocoordinates", relativeTo: Config.baseURL)!
        var request = URLRequest(url: url)
        request.addValue(resource.locale.languageCode ?? "de-DE", forHTTPHeaderField: "Accept-Language")
        return request
    }

    /// Fetch a route between two points.
    ///
    /// - Parameters:
    ///   - origin: origin
    ///   - destination: destination
    ///   - mode: mode
    ///   - locale: locale for descriptions, defaults to `.current`
    ///   - session: session to use, defaults to `.shared`
    ///   - completion: handler
    public static func fetch(from origin: CLLocationCoordinate2D,
                             to destination: CLLocationCoordinate2D,
                             using mode: Route.Mode,
                             locale: Locale = .current,
                             session: URLSession = .shared,
                             completion: @escaping (Result<Route>) -> Void) {
        let resource = RequestResource(origin: origin, destination: destination, mode: mode, locale: locale)
        Route.fetch(resource: resource, session: session, completion: completion)
    }
}
