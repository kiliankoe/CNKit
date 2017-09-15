import XCTest
import CNKit

class TimetableTests: XCTestCase {
    func testDecoding() {
        let json = timetableJSON.data(using: .utf8)!

        let decoded = try! JSONDecoder().decode(Timetable.self, from: json)
        XCTAssertEqual(decoded.week1Name, "11.09.2017 - 17.09.2017 37.KW")
        XCTAssertEqual(decoded.week2Name, "18.09.2017 - 24.09.2017 38.KW")
    }

    func testFetch() {
        let e = expectation(description: "get data")

        let audimax = "136101.0400"
        Timetable.fetch(forRoom: audimax) { result in
            guard let timetable = result.success else {
                XCTFail("got error: \(result)")
                e.fulfill()
                return
            }

            XCTAssertEqual(timetable.week1.count, 5)
            e.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    static var allTests = [
        ("testDecoding", testDecoding),
        ("testFetch", testFetch)
    ]
}

let timetableJSON = """
{"woche1":[{"tag":0,"stunden":[{"ds":1,"fach":"belegt"},{"ds":2,"fach":"belegt"},{"ds":3,"fach":"belegt"},{"ds":4,"fach":"belegt"},{"ds":5,"fach":"belegt"},{"ds":6,"fach":"belegt"},{"ds":7,"fach":"belegt"},{"ds":8,"fach":"belegt"}]},{"tag":1,"stunden":[{"ds":1,"fach":"belegt"},{"ds":2,"fach":"belegt"},{"ds":3,"fach":"belegt"},{"ds":4,"fach":"belegt"},{"ds":5,"fach":"belegt"},{"ds":6,"fach":"belegt"},{"ds":7,"fach":"belegt"},{"ds":8,"fach":"belegt"}]},{"tag":2,"stunden":[{"ds":1,"fach":"belegt"},{"ds":2,"fach":"belegt"},{"ds":3,"fach":"belegt"},{"ds":4,"fach":"belegt"},{"ds":5,"fach":"belegt"},{"ds":6,"fach":"belegt"},{"ds":7,"fach":"belegt"},{"ds":8,"fach":"belegt"}]},{"tag":3,"stunden":[{"ds":1,"fach":"belegt"},{"ds":2,"fach":"belegt"},{"ds":3,"fach":"belegt"},{"ds":4,"fach":"belegt"},{"ds":5,"fach":"belegt"},{"ds":6,"fach":"belegt"},{"ds":7,"fach":"belegt"},{"ds":8,"fach":"belegt"}]},{"tag":4,"stunden":[{"ds":1,"fach":"belegt"},{"ds":2,"fach":"belegt"},{"ds":3,"fach":"belegt"},{"ds":4,"fach":"belegt"},{"ds":5,"fach":"belegt"},{"ds":6,"fach":"belegt"},{"ds":7,"fach":"belegt"},{"ds":8,"fach":"belegt"}]}],"woche1name":"11.09.2017 - 17.09.2017 37.KW","woche2":[{"tag":0,"stunden":[{"ds":1,"fach":"belegt"},{"ds":2,"fach":"belegt"},{"ds":3,"fach":"belegt"},{"ds":4,"fach":"belegt"},{"ds":5,"fach":"belegt"},{"ds":6,"fach":"belegt"},{"ds":7,"fach":"belegt"},{"ds":8,"fach":"belegt"}]},{"tag":1,"stunden":[{"ds":1,"fach":"belegt"},{"ds":2,"fach":"belegt"},{"ds":3,"fach":"belegt"},{"ds":4,"fach":"belegt"},{"ds":5,"fach":"belegt"},{"ds":6,"fach":"belegt"},{"ds":7,"fach":"belegt"},{"ds":8,"fach":"belegt"}]},{"tag":2,"stunden":[{"ds":1,"fach":"belegt"},{"ds":2,"fach":"belegt"},{"ds":3,"fach":"belegt"},{"ds":4,"fach":"belegt"},{"ds":5,"fach":"belegt"},{"ds":6,"fach":"belegt"},{"ds":7,"fach":"belegt"},{"ds":8,"fach":"belegt"}]},{"tag":3,"stunden":[{"ds":1,"fach":"belegt"},{"ds":2,"fach":"belegt"},{"ds":3,"fach":"belegt"},{"ds":4,"fach":"belegt"},{"ds":5,"fach":"belegt"},{"ds":6,"fach":"belegt"},{"ds":7,"fach":"belegt"},{"ds":8,"fach":"belegt"}]},{"tag":4,"stunden":[{"ds":1,"fach":"belegt"},{"ds":2,"fach":"belegt"},{"ds":3,"fach":"belegt"},{"ds":4,"fach":"belegt"},{"ds":5,"fach":"belegt"},{"ds":6,"fach":"belegt"},{"ds":7,"fach":"belegt"},{"ds":8,"fach":"belegt"}]}],"woche2name":"18.09.2017 - 24.09.2017 38.KW"}
"""
