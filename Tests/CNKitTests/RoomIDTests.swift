import XCTest
import CNKit

class RoomIDTests: XCTestCase {
    func testInit() {
        XCTAssertEqual(RoomID(withString: "118100.0220").buildingStructure, "1181")
        XCTAssertEqual(RoomID(withString: "118100.0220").rawFloor, "00")
        XCTAssertEqual(RoomID(withString: "118100.0220").floor, 0)
        XCTAssertEqual(RoomID(withString: "118100.0220").roomID, "0220")
        XCTAssertEqual(RoomID(withString: "118100.0220").rawValue, "118100.0220")

        let literal: RoomID = "351601.0420"
        XCTAssertEqual(literal.buildingStructure, "3516")
    }
}
