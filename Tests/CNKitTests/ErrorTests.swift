import XCTest
import CNKit

class ErrorTests: XCTestCase {
    func testLocalizedDescription() {
        let invalidQuery = CNKit.Error.invalidQuery(reason: "invalid query")
        XCTAssertEqual(invalidQuery.localizedDescription,
                       "The query was invalid and not sent: invalid query")

        let response = CNKit.Error.response
        XCTAssertEqual(response.localizedDescription,
                       "The response data could not be read.")

        let server = CNKit.Error.server(status: 500, error: "some server error")
        XCTAssertEqual(server.localizedDescription,
                       "Server returned status code 500 and error: some server error")

        let decode = CNKit.Error.decode(error: "foo")
        XCTAssertEqual(decode.localizedDescription,
                       "The received data could not be decoded as JSON: foo")

        let reEncoding = CNKit.Error.reEncoding
        XCTAssertEqual(reEncoding.localizedDescription,
                       "The received data had to be re-encoded before parsing, which failed.")

        let cnresourceURL = CNKit.Error.cnresourceURL("url")
        XCTAssertEqual(cnresourceURL.localizedDescription,
                       "The URL to this specific resource could not be read: url")
    }
}

extension String: Swift.Error { }
extension String: LocalizedError {
    public var errorDescription: String? {
        return self
    }
}
