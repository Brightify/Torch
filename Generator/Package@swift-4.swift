// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "TorchGenerator",
    products: [
        .executable(name: "torch_generator", targets: ["torch_generator"]),
        .library(name: "TorchGeneratorFramework", targets: ["TorchGeneratorFramework"])
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/SourceKitten.git", from: "0.15.0"),
        .package(url: "https://github.com/nvzqz/FileKit.git", from: "5.0.0"),
        .package(url: "https://github.com/Carthage/Commandant.git", from: "0.12.0"),
    ],
    targets: [
        .target(name: "TorchGeneratorFramework", dependencies: [
            "SourceKittenFramework",
            "FileKit"
        ]),
        .target(name: "torch_generator", dependencies: [
            "TorchGeneratorFramework",
            "Commandant"
        ]),
    ],
    swiftLanguageVersions: [3, 4]
)
