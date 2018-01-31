import XCTest
@testable import CNKit
import struct CoreLocation.CLLocationCoordinate2D

class ResourceTests: XCTestCase {
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
            "https://navigator.tu-dresden.de/raum/062102.0020",
            "http://navigator.tu-dresden.de/raum/062102.0020",
            "https://www.navigator.tu-dresden.de/raum/062102.0020?d=00.80",
            "https://navigator.tu-dresden.de/barrierefrei/apb",
            "https://navigator.tu-dresden.de/hoersaele/apb",
            "/karten/dresden/geb/apb",
            "karten/dresden/geb/apb",
            "https://navigator.tu-dresden.de/routing/APB/WEB/foot,shortest/@13.755,51.03800000000001,12.z",
        ]

        let validURLs = rawValidURLs.flatMap(URL.init(string:))
        guard rawValidURLs.count == validURLs.count else { XCTFail(); return }

        for url in validURLs {
            XCTAssertNoThrow(try Resource(withURL: url))
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
            XCTAssertThrowsError(try Resource(withURL: url), url.absoluteString)
        }
    }

    func testParse() {
        let roomWithoutDoor = URL(string: "http://navigator.tu-dresden.de/raum/062102.0020")!
        XCTAssertEqual(try! Resource(withURL: roomWithoutDoor),
                       .room(room: "062102.0020", door: nil))

        let roomWithDoor = URL(string: "http://navigator.tu-dresden.de/raum/062102.0020?d=00.80")!
        XCTAssertEqual(try! Resource(withURL: roomWithDoor),
                       .room(room: "062102.0020", door: "00.80"))
    }

    func testFromSearch() {
        let rawValidURLs = [
            "dresden/geb/apb",
            "apb/00/raum/542100.2230",
        ]

        let validURLs = rawValidURLs.flatMap(URL.init(string:))
        guard rawValidURLs.count == validURLs.count else { XCTFail(); return }

        for url in validURLs {
            XCTAssertNoThrow(try Resource.parse(url: url, urlType: .search))
        }

        let rawInvalidURLs = [
            "dresden/geb/apb/00/062102.0020",
            "apb/00/",
            "apb/00",
        ]

        let invalidURLs = rawInvalidURLs.flatMap(URL.init(string:))
        guard rawInvalidURLs.count == invalidURLs.count else { XCTFail(); return }

        for url in invalidURLs {
            XCTAssertThrowsError(try Resource.parse(url: url, urlType: .search), url.absoluteString)
        }
    }

    func testBuildingID() {
        let coord = Resource.coordinate(coord: CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0), zoom: 1)
        XCTAssertNil(coord.buildingID)

        let map = Resource.map(region: "dresden", building: "apb")
        XCTAssertEqual(map.buildingID, "apb")

        let route = Resource.route(origin: "APB", destination: "WEB", mode: .foot)
        XCTAssertNil(route.buildingID)

        let building = Resource.building(building: "apb")
        XCTAssertEqual(building.buildingID, "apb")

        let buildingAcc = Resource.buildingAccessibility(building: "apb")
        XCTAssertEqual(buildingAcc.buildingID, "apb")

        let lectureHalls = Resource.lectureHalls(building: "apb")
        XCTAssertEqual(lectureHalls.buildingID, "apb")

        let floor = Resource.floor(building: "apb", floor: "00")
        XCTAssertEqual(floor.buildingID, "apb")

        let roomFloor = Resource.roomOnFloor(building: "apb", floor: "00", room: "062102.0020")
        XCTAssertEqual(roomFloor.buildingID, "apb")

        let room = Resource.room(room: "062102.0020", door: nil)
        XCTAssertNil(room.buildingID)
    }

    func testURL() {
        let coord = Resource.coordinate(coord: CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0), zoom: 1)
        XCTAssertEqual(coord.url?.absoluteString, "https://navigator.tu-dresden.de/@1.0,1.0,1.z")

        let map = Resource.map(region: "dresden", building: "apb")
        XCTAssertEqual(map.url?.absoluteString, "https://navigator.tu-dresden.de/karten/dresden/geb/apb")

        let route = Resource.route(origin: "APB", destination: "WEB", mode: .foot)
        XCTAssertEqual(route.url?.absoluteString, "https://navigator.tu-dresden.de/routing/APB/WEB/foot,shortest")

        let building = Resource.building(building: "apb")
        XCTAssertEqual(building.url?.absoluteString, "https://navigator.tu-dresden.de/gebaeude/apb")

        let buildingAcc = Resource.buildingAccessibility(building: "apb")
        XCTAssertEqual(buildingAcc.url?.absoluteString, "https://navigator.tu-dresden.de/barrierefrei/apb")

        let lectureHalls = Resource.lectureHalls(building: "apb")
        XCTAssertEqual(lectureHalls.url?.absoluteString, "https://navigator.tu-dresden.de/hoersaele/apb")

        let floor = Resource.floor(building: "apb", floor: "00")
        XCTAssertEqual(floor.url?.absoluteString, "https://navigator.tu-dresden.de/etplan/apb/00")

        let roomFloor = Resource.roomOnFloor(building: "apb", floor: "00", room: "542100.2220")
        XCTAssertEqual(roomFloor.url?.absoluteString, "https://navigator.tu-dresden.de/etplan/apb/00/raum/542100.2220")

        let roomWithoutDoor = Resource.room(room: "542100.2220", door: nil)
        XCTAssertEqual(roomWithoutDoor.url?.absoluteString, "https://navigator.tu-dresden.de/raum/542100.2220")

        let roomWithDoor = Resource.room(room: "542100.2220", door: "00.80")
        XCTAssertEqual(roomWithDoor.url?.absoluteString, "https://navigator.tu-dresden.de/raum/542100.2220?d=00.80")
    }

    func testEquatable() {
        XCTAssertEqual(Resource.coordinate(coord: CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0), zoom: 1),
                       Resource.coordinate(coord: CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0), zoom: 1))
        XCTAssertNotEqual(Resource.coordinate(coord: CLLocationCoordinate2D(latitude: 1.0, longitude: 2.0), zoom: 1),
                       Resource.coordinate(coord: CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0), zoom: 1))
        XCTAssertNotEqual(Resource.coordinate(coord: CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0), zoom: 2),
                          Resource.coordinate(coord: CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0), zoom: 1))

        XCTAssertEqual(Resource.map(region: "region", building: "building"),
                       Resource.map(region: "region", building: "building"))
        XCTAssertNotEqual(Resource.map(region: "foo", building: "building"),
                       Resource.map(region: "region", building: "building"))
        XCTAssertNotEqual(Resource.map(region: "region", building: "foo"),
                          Resource.map(region: "region", building: "building"))

        XCTAssertEqual(Resource.route(origin: "APB", destination: "WEB", mode: .foot),
                       Resource.route(origin: "APB", destination: "WEB", mode: .foot))
        XCTAssertNotEqual(Resource.route(origin: "APB", destination: "WEB", mode: .foot),
                          Resource.route(origin: "FOO", destination: "WEB", mode: .foot))
        XCTAssertNotEqual(Resource.route(origin: "APB", destination: "WEB", mode: .foot),
                          Resource.route(origin: "APB", destination: "FOO", mode: .foot))
        XCTAssertNotEqual(Resource.route(origin: "APB", destination: "WEB", mode: .foot),
                          Resource.route(origin: "APB", destination: "WEB", mode: .car))

        XCTAssertEqual(Resource.building(building: "building"),
                       Resource.building(building: "building"))
        XCTAssertNotEqual(Resource.building(building: "foo"),
                       Resource.building(building: "building"))

        XCTAssertEqual(Resource.buildingAccessibility(building: "building"),
                       Resource.buildingAccessibility(building: "building"))
        XCTAssertNotEqual(Resource.buildingAccessibility(building: "foo"),
                       Resource.buildingAccessibility(building: "building"))

        XCTAssertEqual(Resource.lectureHalls(building: "building"),
                       Resource.lectureHalls(building: "building"))
        XCTAssertNotEqual(Resource.lectureHalls(building: "foo"),
                       Resource.lectureHalls(building: "building"))

        XCTAssertEqual(Resource.floor(building: "building", floor: "floor"),
                       Resource.floor(building: "building", floor: "floor"))
        XCTAssertNotEqual(Resource.floor(building: "foo", floor: "floor"),
                       Resource.floor(building: "building", floor: "floor"))
        XCTAssertNotEqual(Resource.floor(building: "building", floor: "foo"),
                          Resource.floor(building: "building", floor: "floor"))

        XCTAssertEqual(Resource.roomOnFloor(building: "building", floor: "floor", room: "room"),
                       Resource.roomOnFloor(building: "building", floor: "floor", room: "room"))
        XCTAssertNotEqual(Resource.roomOnFloor(building: "foo", floor: "floor", room: "room"),
                       Resource.roomOnFloor(building: "building", floor: "floor", room: "room"))
        XCTAssertNotEqual(Resource.roomOnFloor(building: "building", floor: "foo", room: "room"),
                          Resource.roomOnFloor(building: "building", floor: "floor", room: "room"))
        XCTAssertNotEqual(Resource.roomOnFloor(building: "building", floor: "floor", room: "foo"),
                          Resource.roomOnFloor(building: "building", floor: "floor", room: "room"))

        XCTAssertEqual(Resource.room(room: "room", door: "00.80"),
                       Resource.room(room: "room", door: "00.80"))
        XCTAssertNotEqual(Resource.room(room: "room", door: nil),
                          Resource.room(room: "foo", door: nil))

        XCTAssertNotEqual(Resource.map(region: "region", building: "building"),
                          Resource.building(building: "building"))
    }

    static var allTests = [
        ("testValidURLs", testValidURLs),
        ("testInvalidURLs", testInvalidURLs),
        ("testParse", testParse),
        ("testFromSearch", testFromSearch),
        ("testBuildingID", testBuildingID),
        ("testURL", testURL),
        ("testEquatable", testEquatable),
    ]
}
