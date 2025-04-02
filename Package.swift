// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "JerryWebServer",
    products: [
        .executable(name: "JerryWebServer", targets: ["JerryWebServer"]),
    ],
    dependencies: [
    ],
    targets: [
        .executableTarget(
            name: "JerryWebServer",
            dependencies: []
        )
    ]
)
