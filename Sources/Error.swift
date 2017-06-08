//
//  Error.swift
//  CNKit
//
//  Created by Kilian Költzsch on 08.06.17.
//  Copyright © 2017 CNKit. All rights reserved.
//

import Foundation

enum Error: Swift.Error {
    case request
    case server(statusCode: Int)
    case decode(error: Swift.Error)
    case unknownData(error: Swift.Error)
}
