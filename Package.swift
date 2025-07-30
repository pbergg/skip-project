// swift-tools-version: 6.0
// This is a Skip (https://skip.tools) package.
import PackageDescription

let package = Package(
    name: "skip-project",
    defaultLocalization: "en",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "SkipProject", type: .dynamic, targets: ["SkipProject"]),
    ],
    dependencies: [
        .package(url: "https://source.skip.tools/skip.git", from: "1.6.7"),
        .package(url: "https://source.skip.tools/skip-ui.git", from: "1.0.0"),
        .package(url: "https://github.com/stripe/stripe-ios-spm.git", from: "24.0.0"),
    ],
    targets: [
        .target(name: "SkipProject", dependencies: [
            .product(name: "SkipUI", package: "skip-ui"),
            .product(name: "Stripe", package: "stripe-ios-spm"),
        ], resources: [.process("Resources")], plugins: [.plugin(name: "skipstone", package: "skip")]),
        .testTarget(name: "SkipProjectTests", dependencies: [
            "SkipProject",
            .product(name: "SkipTest", package: "skip")
        ], resources: [.process("Resources")], plugins: [.plugin(name: "skipstone", package: "skip")]),
    ]
)
