// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "SwiftMessages",
    // platforms: [.iOS("9.0")],
    products: [
        .library(name: "SwiftMessages", targets: ["SwiftMessages"])
    ],
    targets: [
        .target(
            name: "SwiftMessages",
            path: "SwiftMessages"
        )
    ]
)
