import PackageDescription

let package = Package(
    name: "TorchGenerator",
    targets: [
        Target(name: "TorchGeneratorFramework"),
        Target(name: "torch_generator", dependencies: [
            .Target(name: "TorchGeneratorFramework")]),
        ],
    dependencies: [
        .Package(url: "https://github.com/jpsim/SourceKitten.git", versions: Version(0, 15, 0)..<Version(0, 17, .max)),
        .Package(url: "https://github.com/TadeasKriz/FileKit.git", Version(4, 0, 2)),
        ],
    exclude: [
        "Tests"
    ]
)
