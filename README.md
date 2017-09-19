# 🗺 CNKit

Access [Campus Navigator](https://navigator.tu-dresden.de) data through a swift wrapper. 



## Installation

CNKit is available through Cocoapods, Carthage/Punic and Swift Package Manager, whatever floats your boat.

```swift
// Cocoapods
pod 'CNKit'

// Carthage
github "kiliankoe/CNKit"

// Swift Package Manager
.package(url: "https://github.com/kiliankoe/CNKit", from: "0.1.0")
```



## Overview

The basic interaction is the same through all model types.

```swift
Campus.fetch { result in
    guard let buildings = result.success else { return }
    for building in buildings {
        print(building.abbrev)
    }
}

// P38, APB, ...
```

All types returned by the API have a method called `fetch` (or very similar) to request either a specific resource or a list of them. Any necessary params are required by the method.
