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
    }

    func testFetchWithFailingLogin() {
        let e = expectation(description: "get error")

        Login.authenticate(withLogin: "foobar", andPassword: "hunter2") { result in
            guard let error = result.failure else {
                XCTFail("Got success: \(result)")
                e.fulfill()
                return
            }

            XCTAssertEqual(error.localizedDescription, "Server returned status code 200 and error: Login incorrect")
            e.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testFetchWithFailingToken() {
        let e = expectation(description: "get error")

        Login.authenticate(withToken: "foobar") { result in
            guard let error = result.failure else {
                XCTFail("Got success: \(result)")
                e.fulfill()
                return
            }

            XCTAssertEqual(error.localizedDescription, "Server returned status code 200 and error: Token has wrong format.")
            e.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testFetchWithLoginAndToken() {
        guard
            let login = ProcessInfo.processInfo.environment["ZIHLOGIN"],
            let password = ProcessInfo.processInfo.environment["ZIHPASSWORD"]
        else {
            XCTFail("Expected to find login details in environment (ZIHLOGIN and ZIHPASSWORD).")
            return
        }

        let e = expectation(description: "get data")

        Login.authenticate(withLogin: login, andPassword: password) { result in
            guard let login = result.success else {
                XCTFail("got error: \(result)")
                e.fulfill()
                return
            }

            XCTAssert(!login.token.isEmpty)

            Login.authenticate(withToken: login.token) { result in
                guard let login = result.success else {
                    XCTFail("got error: \(result)")
                    e.fulfill()
                    return
                }

                XCTAssert(!login.token.isEmpty)

                e.fulfill()
            }
        }

        waitForExpectations(timeout: 5)
    }

    static var allTests = [
        ("testDecoding", testDecoding),
        ("testFetchWithFailingLogin", testFetchWithFailingLogin),
        ("testFetchWithFailingToken", testFetchWithFailingToken),
        ("testFetchWithLoginAndToken", testFetchWithLoginAndToken),
    ]
}
