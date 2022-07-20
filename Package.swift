// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "JWTDecode",
    platforms: [.iOS(.v12), .macOS(.v10_15), .tvOS(.v12), .watchOS("6.2")],
    products: [.library(name: "JWTDecode", targets: ["JWTDecode"])],
    dependencies: [
        .package(name: "Quick", url: "https://github.com/Quick/Quick.git", .upToNextMajor(from: "5.0.0")),
        .package(name: "Nimble", url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "10.0.0"))
    ],
    targets: [
        .target(
            name: "JWTDecode",
            dependencies: [],
            path: "JWTDecode",
            exclude: ["Info.plist"]),
        .testTarget(
            name: "JWTDecode.swiftTests",
            dependencies: ["JWTDecode", "Quick", "Nimble"],
            path: "JWTDecodeTests",
            exclude: ["Info.plist"])
    ])
