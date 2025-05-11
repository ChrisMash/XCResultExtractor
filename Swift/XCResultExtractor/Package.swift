// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XCResultExtractor",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(name: "XCResultTool", targets: ["XCResultTool"]),
        .executable(name: "XCResultExtractor", targets: ["XCResultExtractor"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "XCResultExtractor",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "XCResultTool"
            ]
        ),
        .target(
            name: "XCResultTool"),
        .testTarget(
            name: "XCResultToolTests",
            dependencies: ["XCResultTool"],
            resources: [
                .copy("Assets"),
            ]),
        .testTarget(
            name: "XCResultExtractorTests",
            dependencies: ["XCResultExtractor"])
    ]
)
