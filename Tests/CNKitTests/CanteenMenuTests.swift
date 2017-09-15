import XCTest
import CNKit

class CanteenMenuTests: XCTestCase {
    func testDecoding() {
        let json = """
        {
          "name": "Speiseplan Alte Mensa von heute",
          "diet": [
            [
              "Pizza Fruity & Spicy mit Lauch, Kirschtomaten, Ananas und Chili",
              ""
            ],
            [
              "Auflauf: Canneloni mit Spinatfüllung in Tomatensoße",
              "1.94 EUR / 3.01 EUR"
            ],
            [
              "Terrine: Lauch-Kartoffel-Käsetopf mit Champignons",
              "1.65 EUR / 2.72 EUR"
            ],
            [
              "Pizza Vulcano mit Salami, Paprika und Jalapenos",
              ""
            ],
            [
              "Wok & Grill: Gyros im Fladenbrot mit Eisberg, Tomaten und Tsatsiki",
              "3.10 EUR / 4.80 EUR"
            ],
            [
              "Möhrenköfte mit Aprikosen, dazu Sesam-Minze-Dip, Reis-Bulgurmix und Chinakohlsalat",
              "2.10 EUR / 3.80 EUR"
            ],
            [
              "Tomatisierte Hähnchenbrust mit Kurkumareis und pikantem Spitzkohlsalat",
              "2.70 EUR / 4.40 EUR"
            ],
            [
              "Pasta: Soße mit Cremechampignons und getrockneten Tomaten",
              ""
            ],
            [
              "Pasta: Mailänder Nudelsoße",
              ""
            ],
            [
              "Terrine: Lauch-Kartoffel-Käsetopf mit Champignons und Hackfleisch",
              "1.65 EUR / 2.72 EUR"
            ]
          ]
        }
        """.data(using: .utf8)!

        let menu = try! JSONDecoder().decode(CanteenMenu.self, from: json)

        XCTAssertEqual(menu.menuName, "Speiseplan Alte Mensa von heute")
        XCTAssertEqual(menu.meals.count, 10)
        XCTAssertEqual(menu.meals[0].name, "Pizza Fruity & Spicy mit Lauch, Kirschtomaten, Ananas und Chili")
        XCTAssertNil(menu.meals[0].prices)
        XCTAssertEqual(menu.meals[1].prices, "1.94 EUR / 3.01 EUR")
    }

    func testFetch() {
        let e = expectation(description: "get data")

        CanteenMenu.fetch(forCanteen: "m13") { result in
            guard let menu = result.success else {
                XCTFail("got error \(result)")
                e.fulfill()
                return
            }

            XCTAssert(menu.meals.count > 0)
            e.fulfill()
        }

        waitForExpectations(timeout: 5)
    }
}
