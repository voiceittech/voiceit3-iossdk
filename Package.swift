// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "VoiceIt3-IosSDK",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "VoiceIt3-IosSDK",
            targets: ["VoiceIt3-IosSDK"]
        ),
    ],
    targets: [
        .target(
            name: "VoiceIt3-IosSDK",
            path: "VoiceIt3-IosSDK",
            resources: [
                .process("Classes/Base.lproj"),
            ],
            publicHeadersPath: "Classes"
        ),
    ]
)
