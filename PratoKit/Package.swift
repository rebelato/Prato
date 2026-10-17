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
        .target(
            name: "MealKit",
            resources: [.process("Resources")]
        ),
        .target(
            name: "MealStore",
            dependencies: ["MealKit"]
        ),
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
            name: "HistoryFeature",
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
                "MealStore",
                "HomeFeature",
                "HistoryFeature",
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
            name: "MealStoreTests",
            dependencies: ["MealStore", "MealKit"]
        ),
        .testTarget(
            name: "HomeFeatureTests",
            dependencies: ["HomeFeature", "MealKit"]
        ),
        .testTarget(
            name: "HistoryFeatureTests",
            dependencies: ["HistoryFeature", "MealKit"]
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
                "HistoryFeature",
                "ScanFeature",
                "MealKit",
                .product(name: "Coordinator", package: "CoordinatorFramework")
            ]
        )
    ]
)
