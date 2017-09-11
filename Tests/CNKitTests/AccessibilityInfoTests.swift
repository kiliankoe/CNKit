import Foundation
import XCTest
import CNKit

class AccessibilityInfoTests: XCTestCase {
    func testDecoding() {
        let json = """
        {
          "accessibility": {
            "disabledentrancepresent": "true",
            "elevator": "true",
            "disabledentrances": [
              2
            ],
            "disabledwc": "true",
            "elevatordoorwidth": [
              120
            ]
          },
          "street": "Nöthnitzer Str. 46",
          "name": "Andreas-Pfitzmann-Bau"
        }
        """.data(using: .utf8)!

        let accessibilityInfo = try! JSONDecoder().decode(BuildingComplex.AccessibilityInfo.self, from: json)

        XCTAssertEqual(accessibilityInfo.hasDisabledEntrance, .true)
        XCTAssertEqual(accessibilityInfo.hasElevator, .true)
        XCTAssertEqual(accessibilityInfo.disabledEntrances, [2])
        XCTAssertEqual(accessibilityInfo.hasDisabledRestrooms, .true)
        XCTAssertEqual(accessibilityInfo.elevatorDoorWidths, [120])
    }
}
