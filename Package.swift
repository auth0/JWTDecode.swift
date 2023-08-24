// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JWTDecode",
    platforms: [.iOS(.v13), .macOS(.v11), .tvOS(.v13), .watchOS(.v7)],
    products: [.library(name: "JWTDecode", targets: ["JWTDecode"])],
    dependencies: [
        .package(url: "https://github.com/Quick/Quick.git", from: "7.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "12.0.0"),
    ],
    targets: [
        .target(
            name: "JWTDecode",
            dependencies: [],
            path: "JWTDecode",
            exclude: ["Info.plist"]),
        .testTarget(
            name: "JWTDecode.swiftTests",
            dependencies: [
                "JWTDecode",
                .product(name: "Quick", package: "Quick"),
                .product(name: "Nimble", package: "Nimble"),
            ],
            path: "JWTDecodeTests",
            exclude: ["Info.plist"])
    ])
