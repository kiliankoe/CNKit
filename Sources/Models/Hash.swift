//
//  Hash.swift
//  CNKit
//
//  Created by Kilian Költzsch on 08.06.17.
//  Copyright © 2017 CNKit. All rights reserved.
//

import Foundation

public struct Hash: Codable {
    public let hash: String
    public let encryption: Bool
}

extension Hash: APIResource {
    typealias CollectionType = Hash
    static var expectedEncoding = String.Encoding.utf8

    // RequestConfig serves no purpose here, but some kind of type has to be specified for every APIResource. At least it's uninitializable and defaults to nil.
    struct RequestConfig {
        private init() {}
    }
    typealias RequestResource = RequestConfig?
    static func request(to resource: RequestConfig? = nil) -> URLRequest {
        let url = URL(string: "m/json_gebaeude/hash", relativeTo: Config.baseURL)!
        return URLRequest(url: url)
    }
}
