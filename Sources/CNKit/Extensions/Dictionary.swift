import Foundation

extension Dictionary where Key == String {
    var asURLParams: String {
        return self
            .reduce([]) { (params, param: (key: Key, value: Value)) -> [String] in
                let key = param.key.urlQueryEscaped
                let value = String(describing: param.value).urlQueryEscaped
                return params + ["\(key)=\(value)"]
            }
            .joined(separator: "&")
    }

    var asRequestBodyData: Data {
        guard let data = self.asURLParams.data(using: .utf8) else {
            fatalError("Failed to encode the following urlParams as utf8 data: \(self)")
        }
        return data
    }
}
