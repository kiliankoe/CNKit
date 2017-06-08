import PackageDescription

let package = Package(
    name: "CNKit",
    dependencies: [
        .Package(url: "https://github.com/utahiosmac/Marshal", majorVersion: 1)
    ]
)
