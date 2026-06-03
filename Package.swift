// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "mdlive",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "mdlive",
            path: "Sources/mdlive",
            resources: [
                .copy("Resources")
            ]
        )
    ]
)
