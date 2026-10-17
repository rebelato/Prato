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
        .target(
            name: "DesignSystem",
            resources: [.process("Resources")]
        ),
        .target(name: "MealKit"),
        .target(
            name: "HomeFeature",
            dependencies: [
                "DesignSystem",
                "MealKit",
                .product(name: "Coordinator", package: "CoordinatorFramework")
            ],
            resources: [.process("Resources")]
        ),
        .target(
            name: "ScanFeature",
            dependencies: [
                "DesignSystem",
                "MealKit",
                .product(name: "Coordinator", package: "CoordinatorFramework")
            ],
            resources: [.process("Resources")]
        ),
        .target(
            name: "AppFeature",
            dependencies: [
                "DesignSystem",
                "MealKit",
                "HomeFeature",
                "ScanFeature",
                .product(name: "Coordinator", package: "CoordinatorFramework")
            ],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "MealKitTests",
            dependencies: ["MealKit"]
        ),
        .testTarget(
            name: "HomeFeatureTests",
            dependencies: ["HomeFeature", "MealKit"]
        ),
        .testTarget(
            name: "ScanFeatureTests",
            dependencies: [
                "ScanFeature",
                "MealKit",
                .product(name: "Coordinator", package: "CoordinatorFramework")
            ]
        ),
        .testTarget(
            name: "AppFeatureTests",
            dependencies: [
                "AppFeature",
                "HomeFeature",
                "ScanFeature",
                "MealKit",
                .product(name: "Coordinator", package: "CoordinatorFramework")
            ]
        )
    ]
)
