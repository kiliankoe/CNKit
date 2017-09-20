import XCTest
import CNKit

class CampusTests: XCTestCase {
    func testFetchWithRawData() {
        let e = expectation(description: "get data")

        Campus.fetch(rawDataHandler: { data in
            XCTAssertFalse(data.isEmpty)
            e.fulfill()
        }, completion: {_ in } )

        waitForExpectations(timeout: 5)
    }

    func testFetchWithHashAndRawData() {
        let e = expectation(description: "get data")

        Campus.fetch(ifNewerThanHash: "foobar", rawDataHandler: { data in
            XCTAssertFalse(data.isEmpty)
            e.fulfill()
        }, completion: {_ in } )

        waitForExpectations(timeout: 5)
    }
}
