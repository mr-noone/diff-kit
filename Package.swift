// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "DiffKit",
  platforms: [.iOS(.v8)],
  products: [
    .library(name: "DiffKit", targets: ["DiffKit"])
  ],
  targets: [
    .target(name: "DiffKit", dependencies: []),
    .testTarget(name: "DiffKitTests", dependencies: ["DiffKit"])
  ]
)
