import XCTest
import CNKit
import struct CoreLocation.CLLocationCoordinate2D

class RouteTests: XCTestCase {
    func testDecoding() {
        let json = """
        {
          "route_length": 643.073,
          "instructions": {
            "distances": [
              6.443, 8.169, 2.34, 4.026, 2.533, 9.802, 4.63, 4.732, 0.39900000000006, 5.129, 9.697, 7.178, 7.995, 0  ],
            "indications": [
              0, 2, -1, -2, 2, -2, 2, -2, -1, 2, -2, 2, -2, 4
            ],
            "mins": [
              0, 0, 0, 0, 0, 0, 0, 1, 2, 0, 0, 0, 0, 0
            ],
            "descriptions": [
              "geradeaus", "rechts abbiegen", "leicht links abbiegen", "links abbiegen", "rechts abbiegen", "links abbiegen", "rechts abbiegen auf Nöthnitzer Straße", "links abbiegen auf Helmholtzstraße", "leicht links abbiegen auf Helmholtzstraße", "rechts abbiegen", "links abbiegen", "rechts abbiegen", "links abbiegen", "Ziel erreicht!"
            ]
          },
          "route_time": 7.7165333333333335,
          "coords": [
            13.723288596942021, 51.02547875103679, 13.723312997594022, 51.02553463039252, 13.723399424330877, 51.025517494056764, 13.723424942569991, 51.02551376876638, 13.723595374604956, 51.02554729637982, 13.723866389480227, 51.02560038176776, 13.723928415565084, 51.02572033611805, 13.724515893858282, 51.025621429658415, 13.724554450613732, 51.0257061800146, 13.724904069116057, 51.02564415392975, 13.725308263122475, 51.02557747123191, 13.725434177937377, 51.026235543777844, 13.72545187306669, 51.02633407770844, 13.72521960121139, 51.02715997458607, 13.724981182626959, 51.02816990080856, 13.724973359517158, 51.02820193830584, 13.725510732654723, 51.028261542951945, 13.72560889405628, 51.02827234629405, 13.725467146757255, 51.02877283905684, 13.725430638911515, 51.02888906811675, 13.725823470782268, 51.02890843962673, 13.726245732447037, 51.02892948751739, 13.726233997782334, 51.02900101309272
          ]
        }
        """.data(using: .utf8)!

        let route = try! JSONDecoder().decode(Route.self, from: json)

        XCTAssertEqual(route.length, 643, accuracy: 1)
        XCTAssertEqual(route.duration, 7, accuracy: 1)
        XCTAssertEqual(route.coords.count, 23)
        XCTAssertEqual(route.instructions.count, 14)

        XCTAssertEqual(route.instructions[0].duration, 0)
        XCTAssertEqual(route.instructions[0].description, "geradeaus")
        XCTAssertEqual(route.instructions[0].distance, 6, accuracy: 1)
        XCTAssertEqual(route.instructions[0].indication, .continue)
    }

    func testFetch() {
        let origin = CLLocationCoordinate2D(latitude: 13.7232886, longitude: 51.0254788)
        let destination = CLLocationCoordinate2D(latitude: 13.7262341, longitude: 51.0290011)

        let e = expectation(description: "get data")

        Route.fetch(from: origin, to: destination, using: .foot) { result in
            guard let route = result.success else {
                XCTFail("got error: \(result)")
                e.fulfill()
                return
            }

            XCTAssertEqual(route.length, 643, accuracy: 1)
            XCTAssertEqual(route.duration, 7, accuracy: 1)
            XCTAssertEqual(route.coords.count, 24)
            XCTAssertEqual(route.instructions.count, 14)

            e.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    static var allTests = [
        ("testDecoding", testDecoding),
        ("testFetch", testFetch),
    ]
}
