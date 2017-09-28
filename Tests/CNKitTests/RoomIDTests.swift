import XCTest
import CNKit

class RoomIDTests: XCTestCase {
    func testInit() {
        XCTAssertEqual(RoomID(withString: "118100.0220").buildingStructure, "1181")
        XCTAssertEqual(RoomID(withString: "118100.0220").rawLevel, "00")
        XCTAssertEqual(RoomID(withString: "118100.0220").level, 0)
        XCTAssertEqual(RoomID(withString: "118100.0220").roomID, "0220")
        XCTAssertEqual(RoomID(withString: "118100.0220").fullID, "118100.0220")

        let literal: RoomID = "351601.0420"
        XCTAssertEqual(literal.buildingStructure, "3516")
    }
}
