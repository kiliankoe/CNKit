//
//  HashTests.swift
//  CNKit
//
//  Created by Kilian Költzsch on 08.06.17.
//  Copyright © 2017 CNKit. All rights reserved.
//

import Foundation
import XCTest
import CNKit

class HashTests: XCTestCase {
    func testDecoding() {
        let json = """
{
  "hash": "ddb3f3b560696dc4fca3cb5afc9ce0d54232a37b",
  "encryption": false
}
""".data(using: .utf8)!

        let decoded = try! JSONDecoder().decode(Hash.self, from: json)
        XCTAssertEqual(decoded.hash, "ddb3f3b560696dc4fca3cb5afc9ce0d54232a37b")
    }
}
