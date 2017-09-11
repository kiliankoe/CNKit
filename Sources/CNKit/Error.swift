import Foundation

enum Error: Swift.Error {
    case request(reason: String)
    case server(statusCode: Int)
    case decode(error: Swift.Error)
    case unknownData(error: Swift.Error)
}
