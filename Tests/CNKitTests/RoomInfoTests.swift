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

    func testAccessibilityInfoDecoding() {
        let json = """
        {
          "rollstuhlplätze_vorhanden": "ja",
          "rollstuhlplätze_position": "Vorne",
          "hörschleife_vorhanden": "nein",
          "treppen_im_gestühl": "Nein, die Treppe ist identisch mit den Gestühlstufen",
          "hörschleife_induktiv": "nicht angegeben",
          "erreichbarkeit_barfrei_eingang_ausschilderung_zutreffend": "ja",
          "erreichbarkeit_kommentar": "Lange Umweg",
          "rollstuhlplätze_schwenkbare_Tische_vorhanden": "nein",
          "hörschleife_microport": "nicht angegeben",
          "treppen_handlauf_vorhanden": "nicht angegeben",
          "dozentenpult_fest": "ja",
          "dozentenpult_gleiche_höhe_mit_erster_reihe": "ja",
          "zugang_barrierefrei": "... über einen Hauptzugang",
          "rollstuhlplätze_tischhöhe_verstellbar": "nein",
          "steckdosenplätze_anzahl": 12,
          "dozentenpult_verschiebbar": "nein",
          "zugang_kommentar": "Die Tür ist leicht zu öffnen,genug Platz zum Bewegen.",
          "erreichbarkeit_barfrei_eingang_ausschilderung_vorhanden": "ja",
          "erreichbarkeit_eingang_barrierefrei": "nein",
          "erreichbarkeit_barfrei_eingang_ausschilderung_durchgehend": "ja",
          "zugang_tuer_bewegungsflaeche_breite": "200 cm",
          "steckdosenplätze_lage": "gemischt oder in mehreren Raumbereichen",
          "dozentenpult_höhenverstellbar": "nicht angegeben",
          "hörschleife_qualität_schulnoten": 2,
          "erreichbarkeit_barrierefrei": "Ja, aber auf einem Umweg, der normal nicht gewählt würde",
          "zugang_tuer_bewegungsflaeche_tiefe": "200 cm",
          "zugang_mittels": "kein",
          "zugang_türbreite": "150 cm",
          "dozentenpult_unterfahrbar": "nein",
          "zugang_türklinke_höhe": "115 cm",
          "rollstuhlplätze_anzahl": 2,
          "treppen_antritts_endstufen_markiert": "nicht angegeben",
          "dozentenzone_steuertafeln_rollstuhlgerecht": "ja",
          "dozentenzone_barrierefrei": "ja",
          "rollstuhlplätze_unterfahrbare_tische_vorhanden": "nein"
        }
        """.data(using: .utf8)!

        let info = try! JSONDecoder().decode(RoomInfo.AccessibilityInfo.self, from: json)
        XCTAssertEqual(info.categories.count, 8)

        let zugang = info.categories.first { $0.title == "Zugang" }
        XCTAssertEqual(zugang?.entries.count, 7)

        let tuerbreite = zugang?.entries.first { $0.0 == "Türbreite" }
        XCTAssertEqual(tuerbreite?.1, "150 Cm")
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
        ("testAccessibilityInfoDecoding", testAccessibilityInfoDecoding),
        ("testFetchAccessibiltyBadges", testFetchAccessibiltyBadges),
        ("testFetchDoorplate", testFetchDoorplate)
    ]
}
