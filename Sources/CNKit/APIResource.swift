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
                      session: URLSession,
                      rawDataHandler: ((Data) -> Void)? = nil,
                      completion: @escaping (Result<CollectionType>) -> Void) {

        var request: URLRequest
        do {
            request = try self.request(to: resource)
        } catch {
            completion(.failure(error))
            return
        }

        request.setValue("UTF-8", forHTTPHeaderField: "charset") // if only this were working 100% of the time :/
        request.setValue(Locale.current.languageCode ?? "de-DE", forHTTPHeaderField: "Accept-Language")

        let session = session.dataTask(with: request) { data, response, error in
            guard
                var data = data,
                let response = response as? HTTPURLResponse,
                error == nil
            else {
                completion(.failure(Error.response))
                return
            }

            guard 200...299 ~= response.statusCode else {
                completion(.failure(Error.server(status: response.statusCode, error: nil)))
                return
            }

            // The API is mostly giving back Latin1 encoded data, which isn't compatible with JSONSerialization below.
            // But on some endpoints we do get UTF8 data and then this fails. A default (preferably UTF8) would be fantastic...
            if expectedEncoding == .isoLatin1 {
                guard
                    let isoString = String(data: data, encoding: .isoLatin1),
                    let newData = isoString.data(using: .utf8)
                else {
                    completion(.failure(Error.reEncoding))
                    return
                }
                data = newData
            }

            // Unfortunately there are non-JSON-compliant newlines in the data, so we have to strip those as well
            guard let newlinestrippedData = String(data: data, encoding: .utf8)?
                .replacingOccurrences(of: "\n", with: "")
                .data(using: .utf8)
            else {
                // Maybe the wrong encoding was used to decode the data?
                completion(.failure(Error.reEncoding))
                return
            }

            // To be used for storing raw responses elsewhere.
            rawDataHandler?(data)

            if let error = try? JSONDecoder().decode(APIError.self, from: newlinestrippedData) {
                completion(.failure(Error.server(status: 200, error: error.error)))
                return
            }

            let decoded: CollectionType
            do {
                decoded = try JSONDecoder().decode(CollectionType.self, from: newlinestrippedData)
            } catch let error {
                completion(.failure(Error.decode(error: error)))
                return
            }

            completion(.success(decoded))

        }
        session.resume()
    }
}
