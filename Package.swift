// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JWTDecode",
    products: [
        .library(
            name: "JWTDecode",
            targets: ["JWTDecode"])
    ],
    dependencies: [
         .package(url: "https://github.com/Quick/Quick", .upToNextMajor(from: "3.0.0")),
         .package(url: "https://github.com/Quick/Nimble", .upToNextMajor(from: "9.0.0"))
    ],
    targets: [
        .target(
            name: "JWTDecode",
            dependencies: [],
            path: "JWTDecode"),
        .testTarget(
            name: "JWTDecode.swiftTests",
            dependencies: ["JWTDecode", "Quick", "Nimble"])
    ]
)
