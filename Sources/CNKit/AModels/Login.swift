import Foundation

/// A successful authentication result.
public struct Login: Decodable {
    /// Token to be used for further login requests.
    public let token: String

    // the additional field `login: Bool` apparently serves no purpose since it's
    // `true` if the login worked and doesn't exist otherwise. The error is caught
    // before it even comes to decoding this.
}

extension Login: APIResource {
    typealias CollectionType = Login

    static var expectedEncoding: String.Encoding = .isoLatin1

    struct RequestResource {
        let login: (zihLogin: String, password: String)?
        let token: String?
    }

    static func request(to resource: Login.RequestResource) throws -> URLRequest {
        if let login = resource.login {
            let url = URL(string: "m/json_login/user", relativeTo: Config.baseURL)!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setBody([
                "zihlogin": login.zihLogin,
                "passwort": login.password
            ])
            return request
        } else if let token = resource.token {
            let url = URL(string: "m/json_login/token", relativeTo: Config.baseURL)!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setBody([
                "token": token
            ])
            return request
        }
        throw Error.invalidQuery(reason: "Either login/password or token has to be specified for a login request.")
    }

    /// Authenticate via login/password combination.
    ///
    /// - Parameters:
    ///   - login: ZIH login, e.g. `s1234567`
    ///   - password: password
    ///   - session: session to use, defaults to `.shared`
    ///   - completion: handler
    public static func authenticate(withLogin login: String,
                                    andPassword password: String,
                                    session: URLSession = .shared,
                                    completion: @escaping (Result<Login>) -> Void) {
        let resource = RequestResource(login: (zihLogin: login, password: password), token: nil)
        Login.fetch(resource: resource, session: session, completion: completion)
    }

    /// Authenticate via a previously saved token.
    ///
    /// - Parameters:
    ///   - token: token
    ///   - session: session to use, defaults to `.shared`
    ///   - completion: handler
    public static func authenticate(withToken token: String,
                                    session: URLSession = .shared,
                                    completion: @escaping (Result<Login>) -> Void) {
        let resource = RequestResource(login: nil, token: token)
        Login.fetch(resource: resource, session: session, completion: completion)
    }
}
