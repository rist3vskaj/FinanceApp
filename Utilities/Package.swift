// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Utilities",
    platforms: [
        .iOS(.v13) // Adjust the iOS version as needed
    ],
    products: [
        .library(
            name: "PieChart",
            type: .static,
            targets: ["PieChart"])
    ],
    targets: [
        .target(
            name: "PieChart",
            dependencies: [],
            path: "Sources/PieChart"
        ),
    ]
)
