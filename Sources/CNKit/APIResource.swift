import Foundation

protocol APIResource {
    // The type of data returned when fetching this resource, e.g. self or Array<self>, ...
    associatedtype CollectionType: Decodable

    // How the response for this resource is encoded, see usage of this property below.
    static var expectedEncoding: String.Encoding { get }

    // A type containing the necessary information to request a specific member of this resource.
    associatedtype RequestResource
    // Build the request to fetching a specific member using `RequestResource`.
    static func request(to resource: RequestResource) throws -> URLRequest
}

extension APIResource {
    static func fetch(resource: RequestResource,
                      body: [String: Any]?,
                      session: URLSession,
                      completion: @escaping (Result<CollectionType>) -> Void) throws {
        var request = try self.request(to: resource)
        request.setValue("UTF-8", forHTTPHeaderField: "charset") // if only this were working 100% of the time :/
//        request.setValue(L10n.LANGID.string, forHTTPHeaderField: "Accept-Language") // TODO

        if let body = body {
            assert(request.httpMethod != "GET", "GET requests shouldn't have a body specified")

            guard let bodyData = body.asURLParams.data(using: .utf8) else {
                completion(.failure(Error.request))
                return
            }
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpBody = bodyData
        }

        let session = session.dataTask(with: request) { data, response, error in
            guard
                var data = data,
                let response = response as? HTTPURLResponse,
                error == nil
            else {
                completion(.failure(Error.request))
                return
            }

            guard 200...299 ~= response.statusCode else {
                completion(.failure(Error.server(statusCode: response.statusCode)))
                return
            }

            // The API is mostly giving back Latin1 encoded data, which isn't compatible with JSONSerialization below.
            // But on some endpoints we do get UTF8 data and then this fails. A default (preferably UTF8) would be fantastic...
            if expectedEncoding == .isoLatin1 {
                let isoString = String(data: data, encoding: .isoLatin1)!
                data = isoString.data(using: .utf8)!
            }

            // Unfortunately there's are non-JSON-compliant newlines in the data, so we have to strip those as well
            data = (String(data: data, encoding: .utf8)?
                .replacingOccurrences(of: "\n", with: "")
                .data(using: .utf8))!

            let decoded: CollectionType
            do {
                decoded = try JSONDecoder().decode(CollectionType.self, from: data)
            } catch let error {
                completion(.failure(Error.decode(error: error)))
                return
            }

            completion(.success(decoded))

        }
        session.resume()
    }
}

extension Dictionary where Key == String {
    var asURLParams: String {
        return self
            .reduce([]) { (params, param: (key: Key, value: Value)) -> [String] in
                let _key = "\(param.key)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                let _val = "\(param.value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                guard let key = _key, let val = _val else {
                    return params
                }
                return params + ["\(key)=\(val)"]
            }
            .joined(separator: "&")
    }
}
