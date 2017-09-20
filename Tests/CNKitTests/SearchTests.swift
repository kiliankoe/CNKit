import XCTest
import CNKit

class SearchTests: XCTestCase {
    func testDecoding() {
        let json = """
        {
          "assist": "E017",
          "assist2": "E017",
          "results_geb": [
            [
              "Infopavillion",
              "dresden/geb/m09"
            ],
            [
              "Cafeteria Bib-Lounge",
              "dresden/geb/slub"
            ],
            [
              "Cafeteria Bergstraße",
              "dresden/geb/nmen"
            ]
          ],
          "results_raum": [
            [
              "BIO E17",
              "bio/00/raum/236600.0170"
            ],
            [
              "HEM E17",
              "hem/00/raum/126100.0220"
            ],
            [
              "APB E017",
              "apb/00/raum/542100.2230"
            ]
          ],
          "more_geb": false,
          "more_raum": false,
          "trenn": 0,
          "results_geo": []
        }
        """.data(using: .utf8)!

        let search = try! JSONDecoder().decode(Search.self, from: json)

        XCTAssertEqual(search.autocomplete, "E017")

        XCTAssertEqual(search.buildingResults.count, 3)
        XCTAssertEqual(search.buildingResults[2].title, "Cafeteria Bergstraße")
        XCTAssertEqual(search.buildingResults[2].resource, .map(region: "dresden", building: "nmen"))

        XCTAssertEqual(search.roomResults.count, 3)
        XCTAssertEqual(search.roomResults[2].title, "APB E017")
        XCTAssertEqual(search.roomResults[2].resource, .room(building: "apb", floor: "00", room: "542100.2230"))
    }

    func testFetch() {
        let e = expectation(description: "get data")

        Search.query("E017") { result in
            guard let search = result.success else {
                XCTFail("got error: \(result)")
                e.fulfill()
                return
            }

            XCTAssertEqual(search.autocomplete, "E017")
            XCTAssertEqual(search.buildingResults.count, 0)
            XCTAssertGreaterThanOrEqual(search.roomResults.count, 1)
            XCTAssertEqual(search.roomResults[0].title, "BIO E17")
            XCTAssertEqual(search.roomResults[0].resource, .room(building: "bio", floor: "00", room: "236600.0170"))

            e.fulfill()
        }

        waitForExpectations(timeout: 5)
    }
}
