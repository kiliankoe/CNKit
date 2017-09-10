import Foundation

enum Error: Swift.Error {
    case request
    case server(statusCode: Int)
    case decode(error: Swift.Error)
    case unknownData(error: Swift.Error)
}
