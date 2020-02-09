// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftFLACParser",
    products: [
        .library(
            name: "SwiftFLACParser",
            targets: ["SwiftFLACParser"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/mxcl/Path.swift.git", from: "1.0.1")
    ],
    targets: [
        .systemLibrary(name: "flac",
                       pkgConfig: "flac",
                       providers: [
                           .brew(["flac"])
                       ]),
        .target(
            name: "SwiftFLACParser",
            dependencies: ["flac"]
        ),
        .testTarget(
            name: "SwiftFLACParserTests",
            dependencies: ["SwiftFLACParser", "Path"]
        ),
    ]
)