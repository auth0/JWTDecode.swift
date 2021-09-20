// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "JWTDecode",
    platforms: [
        .iOS(.v9),
        .macOS(.v10_11),
        .watchOS(.v2),
        .tvOS(.v9)
    ],
    products: [
        .library(
            name: "JWTDecode",
            targets: ["JWTDecode"])
    ],
    dependencies: [
        .package(name: "Quick", url: "https://github.com/Quick/Quick.git", .upToNextMajor(from: "4.0.0")),
        .package(name: "Nimble", url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "9.0.0"))
    ],
    targets: [
        .target(
            name: "JWTDecode",
            dependencies: [],
            path: "JWTDecode"),
        .testTarget(
            name: "JWTDecode.swiftTests",
            dependencies: ["JWTDecode", "Quick", "Nimble"])
    ])
