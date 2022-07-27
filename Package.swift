// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "SwiftMessages",
    platforms: [
        .iOS("9.0")
    ],
    products: [
        .library(name: "SwiftMessages", targets: ["SwiftMessages"]),
        .library(name: "SwiftMessages-Dynamic", type: .dynamic, targets: ["SwiftMessages"])
    ],
    targets: [
        .target(
            name: "SwiftMessages",
            path: "SwiftMessages",
            exclude: [
                "Info.plist",
            ],
            resources: [.process("Resources")]
        )
    ]
)
