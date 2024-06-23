// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "SwiftMessages",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "SwiftMessages", targets: ["SwiftMessages"]),
        .library(name: "SwiftMessages-Dynamic", type: .dynamic, targets: ["SwiftMessages"]),
        .library(name: "SwiftMessages-AppExt", targets: ["SwiftMessages", "SwiftMessages-AppExt"]),
    ],
    targets: [
        .target(
            name: "SwiftMessages",
            path: "SwiftMessages",
            exclude: [
                "Info.plist",
            ],
            resources: [.process("Resources")]
        ),
        .target(
            name: "SwiftMessages-AppExt",
            path: "SwiftMessages-AppExt",
            swiftSettings: [
                .define("SWIFTMESSAGES_APP_EXTENSIONS")
            ]
        ),
    ]
)

