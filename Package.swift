// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "VoiceIt3-IosSDK",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15)
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
            ]
        ),
    ]
)
