import Foundation
import XCTest
import CNKit

class HashTests: XCTestCase {
    func testDecoding() {
        let json = """
        {
          "hash": "ddb3f3b560696dc4fca3cb5afc9ce0d54232a37b",
          "encryption": false
        }
        """.data(using: .utf8)!

        let decoded = try! JSONDecoder().decode(Hash.self, from: json)
        XCTAssertEqual(decoded.hash, "ddb3f3b560696dc4fca3cb5afc9ce0d54232a37b")
    }

    func testFetch() {
        let e = expectation(description: "get data")

        Hash.fetch { result in
            guard let hash = result.success else {
                XCTFail("got error")
                e.fulfill()
                return
            }

            XCTAssert(!hash.hash.isEmpty)
            e.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    static var allTests = [
        ("testDecoding", testDecoding),
        ("testFetch", testFetch),
    ]
}
