import XCTest
import CNKit

class SearchTests: XCTestCase {
    func testDecoding() {
        let json = """
        {
          "assist": "E017",
          "assist2": "E017",
          "results_geb": [],
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
        XCTAssert(search.buildingResults.isEmpty)
        XCTAssertEqual(search.roomResults.count, 3)
        XCTAssertEqual(search.roomResults[2].title, "APB E017")
        XCTAssertEqual(search.roomResults[2].resource.absoluteString, "https://navigator.tu-dresden.de/apb/00/raum/542100.2230")
    }

    func testFetch() {
        let e = expectation(description: "get data")

        Search.query("E017") { result in
            guard let search = result.success else {
                XCTFail("got error: \(result)")
                e.fulfill()
                return
            }

            // FIXME: This seems to be broken at the moment :/

            e.fulfill()
        }

        waitForExpectations(timeout: 5)
    }
}
