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
        XCTAssertEqual(Tiles.floorplanURL(building: "apb", floor: 0, x: 0, y: 0, z: .one).absoluteString,
                       "https://navigator.tu-dresden.de/images/etplan_cache/APB00_1/0_0.png/nobase64")
        XCTAssertEqual(Tiles.floorplanURL(building: "apb", floor: -1, x: 0, y: 0, z: .two).absoluteString,
                       "https://navigator.tu-dresden.de/images/etplan_cache/APB-1_2/0_0.png/nobase64")
        XCTAssertEqual(Tiles.floorplanURL(building: "hsz", floor: 1, x: 1, y: 0, z: .four).absoluteString,
                       "https://navigator.tu-dresden.de/images/etplan_cache/HSZ01_4/1_0.png/nobase64")
        XCTAssertEqual(Tiles.floorplanURL(building: "sch", floor: 10, x: 1, y: 1, z: .eight).absoluteString,
                       "https://navigator.tu-dresden.de/images/etplan_cache/SCH10_8/1_1.png/nobase64")
    }

    func testFetchFloorplanTileURLs() {
        let e = expectation(description: "fetch tile URLs")

        Tiles.allFloorplanTiles(forBuilding: "APB", floor: 0, zoomLevel: .two) { tiles in
            XCTAssert(tiles.count > 0)
            e.fulfill()
        }

        waitForExpectations(timeout: 10)
    }
}
