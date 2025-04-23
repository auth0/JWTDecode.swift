// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "JWTDecode",
    platforms: [.iOS(.v14), .macOS(.v11), .tvOS(.v14), .watchOS(.v7), .visionOS(.v1)],
    products: [.library(name: "JWTDecode", targets: ["JWTDecode"])],
    dependencies: [
        .package(url: "https://github.com/Quick/Quick.git", .upToNextMajor(from: "7.0.0")),
        .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "12.0.0")),
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
