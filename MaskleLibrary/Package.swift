// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MaskleLibrary",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "MaskleLibrary",
            targets: ["MaskleLibrary"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/muhiro12/SwiftUtilities", "1.0.0"..<"2.0.0")
    ],
    targets: [
        .target(
            name: "MaskleLibrary",
            dependencies: [
                .product(name: "SwiftUtilities", package: "SwiftUtilities")
            ],
            path: ".",
            exclude: [
                "Tests"
            ],
            sources: [
                "Sources"
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "MaskleLibraryTests",
            dependencies: ["MaskleLibrary"],
            path: "Tests",
            exclude: [
                "MaskleLibrary.xctestplan"
            ]
        )
    ]
)
