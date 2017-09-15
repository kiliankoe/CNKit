import XCTest
import CNKit

class LoginTests: XCTestCase {
    func testDecoding() {
        let successJSON = """
        {
          "login": true,
          "token": "Y0bXcorHzT_gbBsf261rM"
        }
        """.data(using: .utf8)!

        let login = try! JSONDecoder().decode(Login.self, from: successJSON)

        XCTAssertEqual(login.token, "Y0bXcorHzT_gbBsf261rM")
        XCTAssertNil(login.error)

        let errorJSON = """
        {
          "error": "Login incorrect"
        }
        """.data(using: .utf8)!

        let error = try! JSONDecoder().decode(Login.self, from: errorJSON)

        XCTAssertEqual(error.error, "Login incorrect")
        XCTAssertNil(error.token)
    }

    func testFetchWithLogin() {
        guard
            let login = ProcessInfo.processInfo.environment["ZIHLOGIN"],
            let password = ProcessInfo.processInfo.environment["ZIHPASSWORD"]
        else {
            print("\n\nExpected to find login details in environment (ZIHLOGIN and ZIHPASSWORD). Skipping LoginTests.\(#function)\n\n")
            return
        }

        let e = expectation(description: "get data")

        Login.authenticate(withLogin: login, andPassword: password) { result in
            guard let login = result.success else {
                XCTFail("got error: \(result)")
                e.fulfill()
                return
            }

            XCTAssert(!login.token!.isEmpty)
            XCTAssertNil(login.error)

            e.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testFetchWithToken() {
        let e = expectation(description: "get data")

        Login.authenticate(withToken: "krG0IyxqIu_DOrDLwXWQd") { result in
            guard let login = result.success else {
                XCTFail("got error: \(result)")
                e.fulfill()
                return
            }

            XCTAssertNil(login.token)
            XCTAssertEqual(login.error, "Token incorrect")

            e.fulfill()
        }

        waitForExpectations(timeout: 5)
    }
}
