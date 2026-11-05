// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Common",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "Common",
            targets: ["Common"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Common",
            dependencies: [
                //    .product(name: "NukeUI", package: "Nuke"),
            ],
            resources: [
                .process("Resources/Assets.xcassets"),
                .process("Resources/CommonDB.xcdatamodeld"),
                .process("Resources/google.co.uk.cer")
            ],
            swiftSettings: [
                .define("IN_PACKAGE_CODE") // Compiler flag
            ]
        ),
        .testTarget(
            name: "CommonTests",
            dependencies: [
                "Common"
            ],
            swiftSettings: [
                .define("IN_PACKAGE_CODE") // Compiler flag
            ]
        )
    ]
)

for target in package.targets {
    target.swiftSettings = target.swiftSettings ?? []
    target.swiftSettings?.append(
        .unsafeFlags([
            "-Xfrontend", "-warn-long-function-bodies=200", "-Xfrontend", "-warn-long-expression-type-checking=200"
        ])
    )
}
