import Foundation

public enum Campus {
    /// Fetch all building complexes.
    ///
    /// - Parameters:
    ///   - session: session to use, defaults to `.shared`
    ///   - completion: handler
    public static func fetch(session: URLSession = .shared,
                             rawDataHandler: ((Data) -> Void)? = nil,
                             completion: @escaping (Result<[BuildingComplex]>) -> Void) {
        BuildingComplex.fetch(session: session, rawDataHandler: rawDataHandler, completion: completion)
    }

    /// Fetch all building complexes if the current data hash differs from the given one.
    ///
    /// - Parameters:
    ///   - oldHash: given data hash
    ///   - session: session to use, defaults to `.shared`
    ///   - completion: handler
    /// - Warning: Completion handler is only called on error or if newer data was found.
    public static func fetch(ifNewerThanHash oldHash: String,
                             session: URLSession = .shared,
                             rawDataHandler: ((Data) -> Void)? = nil,
                             completion: @escaping (Result<[BuildingComplex]>) -> Void) {
        Hash.fetch(session: session) { result in
            let hash: Hash
            do {
                hash = try result.get()
            } catch {
                completion(.failure(error))
                return
            }
            guard hash.hash != oldHash else { return }

            BuildingComplex.fetch(session: session, rawDataHandler: rawDataHandler, completion: completion)
        }
    }

    /// Decode a list of `BuildingComplex`'es from given data. This takes the data returned
    /// by `m/json_gebaeude/all`, which is the same as `Campus.fetch()`. Use this to provide
    /// initial data to be used if an internet connection is not present for the first start
    /// or if persisting the API responses directly.
    ///
    /// - Parameter data: API response as data
    /// - Returns: decoded API response
    /// - Throws: any errors occurring during JSON decoding
    public static func readFromLocal(data: Data) throws -> [BuildingComplex] {
        return try JSONDecoder().decode([BuildingComplex].self, from: data)
    }
}
