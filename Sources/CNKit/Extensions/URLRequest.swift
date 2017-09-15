import Foundation

extension URLRequest {
    mutating func setBody(_ body: [String: Any]) {
        assert(self.httpMethod != "GET", "GET requests shouldn't have a body")

        guard let bodyData = body.asURLParams.data(using: .utf8) else {
            print("Failed updating request body.")
            return
        }

        self.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        self.httpBody = bodyData
    }
}
