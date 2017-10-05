// swift-tools-version:3.1
import PackageDescription

let package = Package(
    name: "TorchGenerator",
    targets: [
        Target(name: "TorchGeneratorFramework"),
        Target(name: "torch_generator", dependencies: [
            .Target(name: "TorchGeneratorFramework")]),
        ],
    dependencies: [
        .Package(url: "https://github.com/jpsim/SourceKitten.git", versions: Version(0, 15, 0)..<Version(0, 18, .max)),
        .Package(url: "https://github.com/nvzqz/FileKit.git", Version(5, 0, 0)),
        ],
    exclude: [
        "Tests"
    ]
)
