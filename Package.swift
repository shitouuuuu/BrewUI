// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "BrewUI",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "BrewUI", targets: ["BrewUI"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "BrewUI",
            dependencies: [],
            path: "Sources/BrewUI"
        )
    ]
)
