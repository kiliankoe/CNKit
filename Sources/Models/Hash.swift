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

    static var request: URLRequest {
        let url = URL(string: "m/json_gebaeude/hash", relativeTo: Config.baseURL)!
        return URLRequest(url: url)
    }
}
