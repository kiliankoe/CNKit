# 🗺 CNKit

[![Travis](https://img.shields.io/travis/kiliankoe/CNKit.svg)](https://travis-ci.org/kiliankoe/CNKit)
[![Documentation](https://kiliankoe.github.io/CNKit/badge.svg)](https://kiliankoe.github.io/CNKit/)

Access [Campus Navigator](https://navigator.tu-dresden.de) data through a swift wrapper.



## Installation

CNKit is available through Carthage/Punic and Swift Package Manager, whatever floats your boat.

```swift
// Carthage
github "kiliankoe/CNKit"

// Swift Package Manager
.package(url: "https://github.com/kiliankoe/CNKit", from: "latest version")
```



## Overview

The basic interaction is the same through all model types. Here as an example for the all-encompassing [`Campus`](x-source-tag://Campus) type.

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

Further documentation can be found here: https://kiliankoe.github.io/CNKit/
