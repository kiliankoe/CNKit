import XCTest
import CNKit

class BuildingComplexTests: XCTestCase {
    func testDecoding() {
        let json = buildingComplexJSON.data(using: .utf8)!

        let decoded = try! JSONDecoder().decode([BuildingComplex].self, from: json)
        XCTAssertEqual(decoded.count, 2)

        let apb = decoded[1]
        XCTAssertEqual(apb.abbreviation, "APB")
        XCTAssertEqual(apb.name, "Andreas-Pfitzmann-Bau")
        XCTAssertEqual(apb.defaultLevel, "00")
        XCTAssertEqual(apb.accessibilityOverview!["behindwc"], "EG030 beidseitig anfahrbar")
        XCTAssertEqual(apb.entrances.count, 8)
        XCTAssertEqual(apb.imageURLs.count, 2)
        XCTAssertEqual(apb.structures.count, 1)
        XCTAssertEqual(apb.points[0].count, 38)

        let apbb = apb.structures[0]
        XCTAssertEqual(apbb.name, "APB Andreas-Pfitzmann-Bau, Nöthnitzer Str.46")
        XCTAssertEqual(apbb.constructionYear, "2006")
        XCTAssertEqual(apbb.isLandmarked, false)
        XCTAssertEqual(apbb.id, "5421")
        XCTAssertEqual(apbb.address, "Nöthnitzer Str. 46")
        XCTAssertEqual(apbb.zipcode, "01187")
        XCTAssertEqual(apbb.city, "Dresden")

        let he = apb.entrances[0]
        XCTAssertEqual(he.id, 1)
        XCTAssertEqual(he.image, "eingaenge/APB_1.jpg")
        XCTAssertEqual(he.imageURL?.absoluteString, "https://navigator.tu-dresden.de/eingaenge/APB_1.jpg")
        XCTAssertEqual(he.note, "Pförtnerloge  Besetzung 0 - 24 Uhr")
        XCTAssertEqual(he.location!.latitude, 51.0, accuracy: 1) // XCTAssert can't cope with the types if CLLocationDegrees are optional here
        XCTAssertEqual(he.location!.longitude, 13.7, accuracy: 1)
        XCTAssertEqual(he.isAccessible, true)
        XCTAssertEqual(he.hasSteps, nil)
        XCTAssertEqual(he.hasOpenButton, nil)
        XCTAssertEqual(he.isAtGroundLevel, true)
        XCTAssertEqual(he.hasThresholdSmall, nil)
        XCTAssertEqual(he.hasBell, nil)
        XCTAssertEqual(he.hasAccessibilityBell, nil)
        XCTAssertEqual(he.hasStepsBig, nil)
        XCTAssertEqual(he.hasRamp, nil)

        XCTAssertEqual(apb.entrances[1].hasOpenButton, true)

        XCTAssertEqual(apb.resource?.url?.absoluteString, "https://navigator.tu-dresden.de/gebaeude/APB")
    }

    func testFetch() {
        let e = expectation(description: "get data")

        BuildingComplex.fetch { result in
            guard let buildings = result.success else {
                XCTFail("got error: \(result)")
                e.fulfill()
                return
            }

            XCTAssert(buildings.count > 5)
            e.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    static var allTests = [
        ("testDecoding", testDecoding),
        ("testFetch", testFetch),
    ]
}

let buildingComplexJSON = """
[{"krz":"P38","name":"Abstellgeb., Pienner Str.38a","stdetage":"--","barfrei_info":{},"eingänge":[],"bilder":["/gebaeude_galleries/p38/P38_Geb2a.jpg","/gebaeude_galleries/p38/P38_Geb.jpg","/gebaeude_galleries/p38/P38_Geb2b.jpg"],"teilgeb":[],"punkte":[[{"x":13.5803303,"y":50.9786708},{"x":13.5803323,"y":50.9786569},{"x":13.5803451,"y":50.9785656},{"x":13.5803509,"y":50.9785324},{"x":13.5804926,"y":50.9785427},{"x":13.5804902,"y":50.9785591},{"x":13.580472,"y":50.9786811}],[{"x":13.5801898,"y":50.9786683},{"x":13.5802727,"y":50.9786764},{"x":13.5802849,"y":50.9786271},{"x":13.5803058,"y":50.9785423},{"x":13.5802228,"y":50.9785342}]]},{"krz":"APB","name":"Andreas-Pfitzmann-Bau","stdetage":"00","barfrei_info":{"allgemein":"Neben dem Haupteingang ist ein barrierefreier Zugang (behindertengerechte Kennzeichnung -genoppter Fußweg).","barfreihoersal":"E005, E009","behindwc":"EG030 beidseitig anfahrbar","behindparkplatz":"P0500 zwischen Informatik, Heidebroek-Bau und Sporthalle, Zufahrt Nöthnitzer Straße, 16 barrierefreie Stellplätze; P0510 nordöstlich von Informatik, 20 barrierefreie Stellplätze","aufzug":"Personenaufzug, Gleichlader, weitere Aufzüge vorhanden","ansprech":"Frau Waldmann / Frau Rothe Tel.: +49 351 463 37044 Fax: +49 351 463 37284 infostelle@tu-dresden.de","blindenleitsystem_vorhanden":"ja"},"eingänge":[{"adrdoor":1,"bemerkung":"Pförtnerloge  Besetzung 0 - 24 Uhr","ebenerdig":true,"bildURL":"eingaenge/APB_1.jpg","barrierefrei":true,"lon":13.7232438,"lat":51.0254869},{"adrdoor":2,"bemerkung":"Pförtnerloge  Besetzung 0 - 24 Uhr","taster":true,"ebenerdig":true,"bildURL":"eingaenge/APB_2.jpg"},{"adrdoor":3,"bemerkung":"kein offizieller Eingang/Fluchttür","ebenerdig":true,"bildURL":"eingaenge/APB_3.jpg"},{"adrdoor":4,"bemerkung":"kein offizieller Eingang/Fluchttür","ebenerdig":true,"bildURL":"eingaenge/APB_4.jpg"},{"adrdoor":5,"bemerkung":"Wirtschaftseingänge /Treppen","bildURL":"eingaenge/APB_5.jpg"},{"adrdoor":6,"bemerkung":"Wirtschaftseingänge /Treppen","bildURL":"eingaenge/APB_6.jpg"},{"adrdoor":7,"bemerkung":"Tür zum Außenbereich + Fluchttür","bildURL":"eingaenge/APB_7.jpg"},{"adrdoor":8,"bildURL":"eingaenge/APB_8.jpg"}],"bilder":["/gebaeude_galleries/apb/APB_geamt.jpg","/gebaeude_galleries/apb/APB_gesamt2.jpg"],"teilgeb":[{"name":"APB Andreas-Pfitzmann-Bau, Nöthnitzer Str.46","bauj":"2006","denkm":false,"gebnr":"5421","str":"Nöthnitzer Str. 46","plz":"01187","ort":"Dresden"}],"punkte":[[{"x":13.723492,"y":51.025566},{"x":13.7235955,"y":51.0255473},{"x":13.7236918,"y":51.0255298},{"x":13.7236667,"y":51.0254751},{"x":13.7236393,"y":51.0254152},{"x":13.7234559,"y":51.0250149},{"x":13.7227533,"y":51.0251422},{"x":13.7227941,"y":51.0252313},{"x":13.7228828,"y":51.0254249},{"x":13.7228951,"y":51.0254517},{"x":13.7228541,"y":51.0254591},{"x":13.7228166,"y":51.0254659},{"x":13.7228042,"y":51.0254389},{"x":13.7227888,"y":51.0254052},{"x":13.7224548,"y":51.0254658},{"x":13.7224684,"y":51.0254955},{"x":13.7224826,"y":51.0255265},{"x":13.7224436,"y":51.0255335},{"x":13.7224057,"y":51.0255404},{"x":13.7223911,"y":51.0255087},{"x":13.7223794,"y":51.0254831},{"x":13.7221743,"y":51.0255203},{"x":13.7221857,"y":51.0255451},{"x":13.7222006,"y":51.0255776},{"x":13.7223235,"y":51.0258459},{"x":13.7223393,"y":51.0258804},{"x":13.7223497,"y":51.0259031},{"x":13.7232539,"y":51.0257392},{"x":13.7232421,"y":51.0257135},{"x":13.7232277,"y":51.0256822},{"x":13.7231988,"y":51.0256183},{"x":13.7231464,"y":51.0255046},{"x":13.7231579,"y":51.0255025},{"x":13.7232438,"y":51.0254869},{"x":13.7232886,"y":51.0254788},{"x":13.7234395,"y":51.0254515},{"x":13.7234652,"y":51.0255075},{"x":13.7234723,"y":51.025523}]]}]
"""
