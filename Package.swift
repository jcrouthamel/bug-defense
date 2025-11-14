// swift-tools-version:6.2
import PackageDescription

let package = Package(
    name: "BugDefense",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "BugDefense",
            targets: ["BugDefense"]),
        .executable(
            name: "BugDefenseApp",
            targets: ["BugDefenseApp"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "BugDefense",
            dependencies: []),
        .executableTarget(
            name: "BugDefenseApp",
            dependencies: ["BugDefense"]),
        .testTarget(
            name: "BugDefenseTests",
            dependencies: ["BugDefense"]),
    ]
)
