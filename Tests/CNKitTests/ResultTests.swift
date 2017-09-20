import XCTest
@testable import CNKit

class ResultTests: XCTestCase {
    var success: Result<String>!
    var failure: Result<String>!

    override func setUp() {
        success = Result(success: "success")
        failure = Result<String>(failure: CNKit.Error.reEncoding)
    }

    func testInit() {
        XCTAssertEqual(success.success, "success")
        XCTAssertNil(success.failure)

        XCTAssertNil(failure.success)
        XCTAssertNotNil(failure.failure)
    }

    func testGet() {
        XCTAssertNoThrow(try success.get())
        XCTAssertThrowsError(try failure.get())
    }

    func testNilCoalescing() {
        XCTAssertEqual(success ?? "coalescing", "success")
        XCTAssertEqual(failure ?? "coalescing", "coalescing")
    }
}
