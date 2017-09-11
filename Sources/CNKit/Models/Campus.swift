import Foundation

public enum Campus {
    /// Fetch all building complexes.
    ///
    /// - Parameters:
    ///   - session: session to use, defaults to `.shared`
    ///   - completion: handler
    public static func fetch(session: URLSession = .shared,
                             completion: @escaping (Result<[BuildingComplex]>) -> Void) {
        BuildingComplex.fetchAll(session: session, completion: completion)
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

            BuildingComplex.fetchAll(session: session, completion: completion)
        }
    }
}
