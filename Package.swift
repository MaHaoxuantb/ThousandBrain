// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ThousandBrain",
    products: [
        .executable(
            name: "ThousandBrain",
            targets: ["ThousandBrain"]
        )
    ],
    targets: [
        .executableTarget(
            name: "ThousandBrain",
            path: "Sources/ThousandBrain"
        )
    ]
)
