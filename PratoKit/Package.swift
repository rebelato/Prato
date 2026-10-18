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
        .package(url: "https://github.com/rebelato/CoordinatorFramework", from: "2.0.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "13.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.19.6")
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
            name: "FoodRecognition",
            dependencies: ["MealKit"]
        ),
        .target(
            name: "GeminiAnalysis",
            dependencies: [
                "MealKit",
                "FoodRecognition",
                .product(name: "FirebaseAILogic", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAppCheck", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCore", package: "firebase-ios-sdk")
            ]
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
                "GeminiAnalysis",
                "HomeFeature",
                "HistoryFeature",
                "ScanFeature",
                .product(name: "Coordinator", package: "CoordinatorFramework")
            ],
            resources: [.process("Resources")]
        ),
        .target(
            name: "SnapshotTestSupport",
            dependencies: [
                "DesignSystem",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ],
            path: "Tests/SnapshotTestSupport"
        ),
        .testTarget(
            name: "MealKitTests",
            dependencies: ["MealKit"]
        ),
        .testTarget(
            name: "FoodRecognitionTests",
            dependencies: ["FoodRecognition", "MealKit"]
        ),
        .testTarget(
            name: "MealStoreTests",
            dependencies: ["MealStore", "MealKit"]
        ),
        .testTarget(
            name: "HomeFeatureTests",
            dependencies: ["HomeFeature", "MealKit", "SnapshotTestSupport"],
            exclude: ["__Snapshots__"]
        ),
        .testTarget(
            name: "HistoryFeatureTests",
            dependencies: ["HistoryFeature", "MealKit", "SnapshotTestSupport"],
            exclude: ["__Snapshots__"]
        ),
        .testTarget(
            name: "ScanFeatureTests",
            dependencies: [
                "ScanFeature",
                "MealKit",
                "SnapshotTestSupport",
                .product(name: "Coordinator", package: "CoordinatorFramework")
            ],
            exclude: ["__Snapshots__"]
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
