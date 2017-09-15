import XCTest
import CNKit

class RoomInfoTests: XCTestCase {
    func testDecoding() {
        let e005JSON = """
        {
          "routing": true,
          "accessibility": {
            "doorwidth": 120,
            "door": "true",
            "markedsteps": "NA",
            "hearingloop_microport": "NA",
            "wheelchairspaces": 0,
            "hearingloop_inductive": "NA",
            "lecturer": "true",
            "wheelchairspace_present": "true"
          },
          "name": "E005",
          "type": 23
        }
        """.data(using: .utf8)!

        let e005 = try! JSONDecoder().decode(RoomInfo.self, from: e005JSON)

        XCTAssertEqual(e005.name, "E005")
        XCTAssertEqual(e005.isRoutable, true)
        XCTAssertEqual(e005.type, .seminarroom)

        XCTAssertEqual(e005.accessibilityBadge?.doorIsAccessible, .true)
        XCTAssertEqual(e005.accessibilityBadge?.doorwidth, 120)
        XCTAssertEqual(e005.accessibilityBadge?.stepsAreMarked, .nodata)
        XCTAssertEqual(e005.accessibilityBadge?.hearingloopMicroport, .nodata)
        XCTAssertEqual(e005.accessibilityBadge?.hearingloopInductive, .nodata)
        XCTAssertEqual(e005.accessibilityBadge?.wheelchairSpacesAvailable, .true)
        XCTAssertEqual(e005.accessibilityBadge?.wheelchairSpacesCount, 0)
        XCTAssertEqual(e005.accessibilityBadge?.lecturerZoneIsAccessible, .true)

        XCTAssertNil(e005.doorplate)

        let asbBueroJSON = """
        {
          "routing": false,
          "name": "02-011",
          "type": 29,
          "doorplate": {
            "names": [
              "Romy Habenicht",
              ""
            ],
            "functions": [
              "Sekretariat",
              ""
            ],
            "chair": "",
            "textarea": "Anmeldung für Dr.-Ing. habil. Uwe Reuter\\n\\nÖffnungszeiten:\\nMontag u. Dienstag: 9.00 Uhr - 13.00 Uhr\\nMittwoch: 9.00 Uhr - 11.00 Uhr\\nDonnerstag u. Freitag: 9.00 Uhr - 13.00 Uhr",
            "department": "Fakultätsrechenzentrum",
            "faculty": "Fakultät Bauingenieurwesen"
          }
        }
        """.data(using: .utf8)!

        let asbBuero = try! JSONDecoder().decode(RoomInfo.self, from: asbBueroJSON)

        XCTAssertEqual(asbBuero.name, "02-011")

        XCTAssertEqual(asbBuero.doorplate?.people.count, 1)
        XCTAssertEqual(asbBuero.doorplate?.people[0].name, "Romy Habenicht")
        XCTAssertEqual(asbBuero.doorplate?.people[0].function, "Sekretariat")
        XCTAssertEqual(asbBuero.doorplate?.chair, "")
        XCTAssert(asbBuero.doorplate!.text.contains("Öffnungszeiten:\nMontag"))
        XCTAssertEqual(asbBuero.doorplate?.department, "Fakultätsrechenzentrum")
        XCTAssertEqual(asbBuero.doorplate?.faculty, "Fakultät Bauingenieurwesen")
    }

    func testFetchAccessibiltyBadges() {
        let e = expectation(description: "get data")

        RoomInfo.fetch(forRoom: "542100.2100") { result in
            guard let room = result.success else {
                XCTFail("got error: \(result)")
                e.fulfill()
                return
            }

            XCTAssertEqual(room.name, "E005")
            XCTAssertEqual(room.accessibilityBadge?.doorIsAccessible, .true)

            e.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testFetchDoorplate() {
        let e = expectation(description: "get data")

        RoomInfo.fetch(forRoom: "352402.0110") { result in
            guard let room = result.success else {
                XCTFail("got error: \(result)")
                e.fulfill()
                return
            }

            XCTAssertEqual(room.name, "02-011")
            XCTAssertEqual(room.doorplate?.faculty, "Fakultät Bauingenieurwesen")

            e.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    static var allTests = [
        ("testDecoding", testDecoding),
        ("testFetchAccessibiltyBadges", testFetchAccessibiltyBadges),
        ("testFetchDoorplate", testFetchDoorplate)
    ]
}
