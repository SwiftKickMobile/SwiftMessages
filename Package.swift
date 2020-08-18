// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "SwiftMessages",
    platforms: [.iOS("9.0")],
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
