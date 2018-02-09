import Foundation

internal extension URL {
    init?(cnPath path: String) {
        if let url = URL(string: path, relativeTo: Config.baseURL) {
            self = url
        } else {
            return nil
        }
    }

    /// Check if the `Content-Length` header in a HEAD response is != 0.
    /// - Warning: Runs synchronously blocking execution on the current thread.
    var pointsToExistingResource: Bool {
        let sema = DispatchSemaphore(value: 0)

        var contentLength = "0"

        var request = URLRequest(url: self)
        request.httpMethod = "HEAD"
        let task = URLSession.shared.dataTask(with: request) { _, response, _ in
            guard
                let response = response as? HTTPURLResponse,
                let content = response.allHeaderFields["Content-Length"] as? String
            else {
                return
            }
            contentLength = content
            sema.signal()
        }
        task.resume()

        sema.wait()

        return contentLength != "0"
    }
}
