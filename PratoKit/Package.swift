// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "PratoKit",
    defaultLocalization: "pt-BR",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "AppFeature", targets: ["AppFeature"])
    ],
    dependencies: [
        .package(url: "https://github.com/rebelato/CoordinatorFramework", from: "2.0.0")
    ],
    targets: [
        .target(name: "DesignSystem"),
        .target(
            name: "HomeFeature",
            dependencies: [
                "DesignSystem",
                .product(name: "Coordinator", package: "CoordinatorFramework")
            ],
            resources: [.process("Resources")]
        ),
        .target(
            name: "AppFeature",
            dependencies: [
                "DesignSystem",
                "HomeFeature",
                .product(name: "Coordinator", package: "CoordinatorFramework")
            ],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "HomeFeatureTests",
            dependencies: ["HomeFeature"]
        ),
        .testTarget(
            name: "AppFeatureTests",
            dependencies: [
                "AppFeature",
                "HomeFeature",
                .product(name: "Coordinator", package: "CoordinatorFramework")
            ]
        )
    ]
)
