import XCTest
import CNKit

class TilesTests: XCTestCase {
    func testMapURL() {
        XCTAssertEqual(Tiles.mapURL(x: 0, y: 0, z: 0).absoluteString,
                       "https://navigator.tu-dresden.de/tileserver/0/0/0.png/nobase64")
        XCTAssertEqual(Tiles.mapURL(x: 1, y: 2, z: 3).absoluteString,
                       "https://navigator.tu-dresden.de/tileserver/3/1/2.png/nobase64")
    }

    func testFloorplanURL() {
        XCTAssertEqual(Tiles.floorplanURL(x: 0, y: 0, z: 0).absoluteString,
                       "https://navigator.tu-dresden.de/images/etplan_cache/APB00_0/0_0.png/nobase64")
        XCTAssertEqual(Tiles.floorplanURL(x: 1, y: 2, z: 3).absoluteString,
                       "https://navigator.tu-dresden.de/images/etplan_cache/APB00_3/1_2.png/nobase64")
    }
}
