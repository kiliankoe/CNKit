//
//  Error.swift
//  CNKit
//
//  Created by Kilian Költzsch on 08.06.17.
//  Copyright © 2017 CNKit. All rights reserved.
//

import Foundation

// TODO: Evaluate these
enum Error: Swift.Error {
    case request
    case server
    case decode
    case unknownData(error: Swift.Error)
    case fatal
}
