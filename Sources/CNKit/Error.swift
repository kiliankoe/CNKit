import Foundation

/// Any possible error occurring during the execution of CNKit.
public enum Error: Swift.Error {
    /// The query was invalid and not sent.
    case invalidQuery(reason: String)
    /// The response data could not be read.
    case response
    /// The server returned a status code != 2xx or an error message.
    case server(status: Int, error: String?)
    /// The received data could not be decoded as JSON.
    case decode(error: Swift.Error)
    /// The received data had to be re-encoded before parsing, which failed.
    case reEncoding
    /// The URL to this specific resource could not be read.
    case cnresourceURL(String)
}

extension Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidQuery(reason: let reason):
            return "The query was invalid and not sent: \(reason)"
        case .response:
            return "The response data could not be read."
        case .server(status: let statusCode, error: let errorDescription):
            var str = "Server returned status code \(statusCode)"
            if let errorDescription = errorDescription {
                str += " and error: \(errorDescription)"
            }
            return str
        case .decode(error: let error):
            return "The received data could not be decoded as JSON: \(error.localizedDescription)"
        case .reEncoding:
            return "The received data had to be re-encoded before parsing, which failed."
        case .cnresourceURL(let resource):
            return "The URL to this specific resource could not be read: \(resource)"
        }
    }
}
