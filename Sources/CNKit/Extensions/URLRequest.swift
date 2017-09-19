import Foundation

extension URLRequest {
    mutating func setBody(_ body: [String: Any]) {
        assert(self.httpMethod != "GET", "GET requests shouldn't have a body")

        self.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        self.httpBody = body.asRequestBodyData
    }
}
