import XCTest
@testable import CNKit
import MapKit

class MKMapRectTests: XCTestCase {
    func testResize() {
        let origin = MKMapPoint(x: 1.0, y: 1.0)
        let size = MKMapSize(width: 1.0, height: 2.0)
        var rect = MKMapRect(origin: origin, size: size)

        rect.resize(2.0)
        XCTAssertEqual(rect.size.width, 3.0)
        XCTAssertEqual(rect.size.height, 4.0)
        XCTAssertEqual(rect.origin.x, 0.0)
        XCTAssertEqual(rect.origin.y, 0.0)

        rect.resize(3.0)
        XCTAssertEqual(rect.size.width, 6.0)
        XCTAssertEqual(rect.size.height, 7.0)
        XCTAssertEqual(rect.origin.x, -1.5)
        XCTAssertEqual(rect.origin.y, -1.5)
    }
}
