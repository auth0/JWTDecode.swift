// swift-tools-version:5.0

import PackageDescription

let package = Package(
  name: "JWTDecode",
  platforms: [
        .macOS(.v10_11), .iOS(.v9), .tvOS(.v9), .watchOS(.v4)
    ],
    products: [
        .library(name: "JWTDecode", targets: ["JWTDecode"]),
    ],
  dependencies: [
        .package(url: "https://github.com/Quick/Quick.git", from: "2.1.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "8.0.0")
  ],

  targets: [
    .target(
        name: "JWTDecode",
        dependencies: []),
    .testTarget(
        name: "JWTDecodeTests",
        dependencies: ["JWTDecode", "Quick", "Nimble"])
    // .testTarget(
    //     name: "JWTDecodeObjCTests",
    //     dependencies: ["JWTDecode", "Quick", "Nimble"])
  ]
)