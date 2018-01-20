import PackageDescription

let package = Package(
    name: "JSON",
    dependencies: [
        .Package(url: "https://github.com/nfam/byte.swift.git", majorVersion: 0)
    ]
)
