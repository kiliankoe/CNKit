import XCTest
@testable import CNKit
import struct CoreLocation.CLLocationCoordinate2D

class CNResourceTests: XCTestCase {
    func testValidURLs() {
        let rawValidURLs = [
            "https://navigator.tu-dresden.de/@13.732,51.02839999999999,15.z",
            "https://navigator.tu-dresden.de/raum/apb/00/542100.2230",
            "https://navigator.tu-dresden.de/etplan/apb/00/raum/542100.2230",
            "https://navigator.tu-dresden.de/gebaeude/apb",
            "https://navigator.tu-dresden.de/karten/dresden/geb/apb",
            "https://navigator.tu-dresden.de/etplan/apb/00",
            "https://navigator.tu-dresden.de/gebaeude/biz",
            "https://navigator.tu-dresden.de/karten/johannstadt/geb/biz",
            "https://navigator.tu-dresden.de/etplan/biz/02/raum/062102.0020",
            "https://navigator.tu-dresden.de/raum/biz/02/062102.0020",
            "http://navigator.tu-dresden.de/raum/biz/02/062102.0020",
            "https://www.navigator.tu-dresden.de/raum/biz/02/062102.0020",
            "https://navigator.tu-dresden.de/barrierefrei/apb",
            "https://navigator.tu-dresden.de/hoersaele/apb",
            "/karten/dresden/geb/apb",
            "karten/dresden/geb/apb",
        ]

        let validURLs = rawValidURLs.flatMap(URL.init(string:))
        guard rawValidURLs.count == validURLs.count else { XCTFail(); return }

        for url in validURLs {
            XCTAssertNoThrow(try CNResource(withURL: url))
        }
    }

    func testInvalidURLs() {
        let rawInvalidURLs = [
            "https://navigator.tu-dresden.de/@13.732,51.02839999999999",
            "https://navigator.tu-dresden.de/@13.732",
            "https://navigator.tu-dresden.de/13.732,51.02839999999999,15.z",
            "https://navigator.tu-dresden.de/apb/00/542100.2230",
            "https://navigator.tu-dresden.de/etplan/apb/00/542100.2230",
            "https://navigator.tu-dresden.de/gebaede/biz",
            "https://navigator.tu-dresden.de/etplan//00",
            "https://navigator.tu-dresden.de/etplan/apb",
            "https://navigator.tu-dresden.de/gebaeude/biz/00",
            "https://navigator.tu-dresden.de/gebaeude/",
            "https://navigator.tu-dresden.de/gebaeude//",
            "https://navigator.tu-dresden.de/barrierefrei/apb/00",
            "https://navigator.tu-dresden.de/barrierefrei",
            "https://navigator.tu-dresden.de/hoersaele/",
            "https://navigator.tu-dresden.de/karten/geb/apb",
            "https://navigator.tu-dresden.de/raum/02/062102.0020",
        ]

        let invalidURLs = rawInvalidURLs.flatMap(URL.init(string:))
        guard rawInvalidURLs.count == invalidURLs.count else { XCTFail(); return }

        for url in invalidURLs {
            XCTAssertThrowsError(try CNResource(withURL: url), url.absoluteString)
        }
    }

    func testFromSearch() {
        let rawValidURLs = [
            "dresden/geb/apb",
            "apb/00/raum/542100.2230",
        ]

        let validURLs = rawValidURLs.flatMap(URL.init(string:))
        guard rawValidURLs.count == validURLs.count else { XCTFail(); return }

        for url in validURLs {
            XCTAssertNoThrow(try CNResource.parse(url: url, urlType: .search))
        }

        let rawInvalidURLs = [
            "dresden/geb/apb/00/062102.0020",
            "apb/00/",
            "apb/00",
        ]

        let invalidURLs = rawInvalidURLs.flatMap(URL.init(string:))
        guard rawInvalidURLs.count == invalidURLs.count else { XCTFail(); return }

        for url in invalidURLs {
            XCTAssertThrowsError(try CNResource.parse(url: url, urlType: .search), url.absoluteString)
        }
    }

    func testBuildingID() {
        let coord = CNResource.coordinate(coord: CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0), zoom: 1)
        XCTAssertNil(coord.buildingID)

        let map = CNResource.map(region: "dresden", building: "apb")
        XCTAssertEqual(map.buildingID, "apb")

        let building = CNResource.building(building: "apb")
        XCTAssertEqual(building.buildingID, "apb")

        let buildingAcc = CNResource.buildingAccessibility(building: "apb")
        XCTAssertEqual(buildingAcc.buildingID, "apb")

        let lectureHalls = CNResource.lectureHalls(building: "apb")
        XCTAssertEqual(lectureHalls.buildingID, "apb")

        let floor = CNResource.floor(building: "apb", floor: "00")
        XCTAssertEqual(floor.buildingID, "apb")

        let roomFloor = CNResource.roomOnFloor(building: "apb", floor: "00", room: "062102.0020")
        XCTAssertEqual(roomFloor.buildingID, "apb")

        let room = CNResource.room(building: "apb", floor: "00", room: "062102.0020")
        XCTAssertEqual(room.buildingID, "apb")
    }

    func testURL() {
        let coord = CNResource.coordinate(coord: CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0), zoom: 1)
        XCTAssertEqual(coord.url?.absoluteString, "https://navigator.tu-dresden.de/@1.0,1.0,1.z")

        let map = CNResource.map(region: "dresden", building: "apb")
        XCTAssertEqual(map.url?.absoluteString, "https://navigator.tu-dresden.de/karten/dresden/geb/apb")

        let building = CNResource.building(building: "apb")
        XCTAssertEqual(building.url?.absoluteString, "https://navigator.tu-dresden.de/gebaeude/apb")

        let buildingAcc = CNResource.buildingAccessibility(building: "apb")
        XCTAssertEqual(buildingAcc.url?.absoluteString, "https://navigator.tu-dresden.de/barrierefrei/apb")

        let lectureHalls = CNResource.lectureHalls(building: "apb")
        XCTAssertEqual(lectureHalls.url?.absoluteString, "https://navigator.tu-dresden.de/hoersaele/apb")

        let floor = CNResource.floor(building: "apb", floor: "00")
        XCTAssertEqual(floor.url?.absoluteString, "https://navigator.tu-dresden.de/etplan/apb/00")

        let roomFloor = CNResource.roomOnFloor(building: "apb", floor: "00", room: "542100.2220")
        XCTAssertEqual(roomFloor.url?.absoluteString, "https://navigator.tu-dresden.de/etplan/apb/00/raum/542100.2220")

        let room = CNResource.room(building: "apb", floor: "00", room: "542100.2220")
        XCTAssertEqual(room.url?.absoluteString, "https://navigator.tu-dresden.de/raum/apb/00/542100.2220")
    }

    func testEquatable() {
        XCTAssertEqual(CNResource.coordinate(coord: CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0), zoom: 1),
                       CNResource.coordinate(coord: CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0), zoom: 1))
        XCTAssertNotEqual(CNResource.coordinate(coord: CLLocationCoordinate2D(latitude: 1.0, longitude: 2.0), zoom: 1),
                       CNResource.coordinate(coord: CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0), zoom: 1))
        XCTAssertNotEqual(CNResource.coordinate(coord: CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0), zoom: 2),
                          CNResource.coordinate(coord: CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0), zoom: 1))

        XCTAssertEqual(CNResource.map(region: "region", building: "building"),
                       CNResource.map(region: "region", building: "building"))
        XCTAssertNotEqual(CNResource.map(region: "foo", building: "building"),
                       CNResource.map(region: "region", building: "building"))
        XCTAssertNotEqual(CNResource.map(region: "region", building: "foo"),
                          CNResource.map(region: "region", building: "building"))

        XCTAssertEqual(CNResource.building(building: "building"),
                       CNResource.building(building: "building"))
        XCTAssertNotEqual(CNResource.building(building: "foo"),
                       CNResource.building(building: "building"))

        XCTAssertEqual(CNResource.buildingAccessibility(building: "building"),
                       CNResource.buildingAccessibility(building: "building"))
        XCTAssertNotEqual(CNResource.buildingAccessibility(building: "foo"),
                       CNResource.buildingAccessibility(building: "building"))

        XCTAssertEqual(CNResource.lectureHalls(building: "building"),
                       CNResource.lectureHalls(building: "building"))
        XCTAssertNotEqual(CNResource.lectureHalls(building: "foo"),
                       CNResource.lectureHalls(building: "building"))

        XCTAssertEqual(CNResource.floor(building: "building", floor: "floor"),
                       CNResource.floor(building: "building", floor: "floor"))
        XCTAssertNotEqual(CNResource.floor(building: "foo", floor: "floor"),
                       CNResource.floor(building: "building", floor: "floor"))
        XCTAssertNotEqual(CNResource.floor(building: "building", floor: "foo"),
                          CNResource.floor(building: "building", floor: "floor"))

        XCTAssertEqual(CNResource.roomOnFloor(building: "building", floor: "floor", room: "room"),
                       CNResource.roomOnFloor(building: "building", floor: "floor", room: "room"))
        XCTAssertNotEqual(CNResource.roomOnFloor(building: "foo", floor: "floor", room: "room"),
                       CNResource.roomOnFloor(building: "building", floor: "floor", room: "room"))
        XCTAssertNotEqual(CNResource.roomOnFloor(building: "building", floor: "foo", room: "room"),
                          CNResource.roomOnFloor(building: "building", floor: "floor", room: "room"))
        XCTAssertNotEqual(CNResource.roomOnFloor(building: "building", floor: "floor", room: "foo"),
                          CNResource.roomOnFloor(building: "building", floor: "floor", room: "room"))

        XCTAssertEqual(CNResource.room(building: "building", floor: "floor", room: "room"),
                       CNResource.room(building: "building", floor: "floor", room: "room"))
        XCTAssertNotEqual(CNResource.room(building: "foo", floor: "floor", room: "room"),
                       CNResource.room(building: "building", floor: "floor", room: "room"))
        XCTAssertNotEqual(CNResource.room(building: "building", floor: "foo", room: "room"),
                          CNResource.room(building: "building", floor: "floor", room: "room"))
        XCTAssertNotEqual(CNResource.room(building: "building", floor: "floor", room: "foo"),
                          CNResource.room(building: "building", floor: "floor", room: "room"))

        XCTAssertNotEqual(CNResource.map(region: "region", building: "building"),
                          CNResource.building(building: "building"))
    }

    static var allTests = [
        ("testValidURLs", testValidURLs),
        ("testInvalidURLs", testInvalidURLs),
        ("testFromSearch", testFromSearch),
        ("testBuildingID", testBuildingID),
        ("testURL", testURL),
        ("testEquatable", testEquatable),
    ]
}
