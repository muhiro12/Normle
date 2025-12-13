// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NormleLibrary",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "NormleLibrary",
            targets: ["NormleLibrary"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/muhiro12/SwiftUtilities", "1.0.0"..<"2.0.0")
    ],
    targets: [
        .target(
            name: "NormleLibrary",
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
            name: "NormleLibraryTests",
            dependencies: ["NormleLibrary"],
            path: "Tests",
            exclude: [
                "NormleLibrary.xctestplan"
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
