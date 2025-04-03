// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "JerryWebServer",
    products: [
        .executable(name: "JerryWebServer", targets: ["JerryWebServer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0")
    ],
    targets: [
        .executableTarget(
            name: "JerryWebServer",
            dependencies: [
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio")
            ]
        )
    ]
)
