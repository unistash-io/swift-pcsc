// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-pcsc",
    platforms: [
        .macOS("14.0"),
    ],
    products: [
        .library(name: "PCSCKit", targets: ["PCSCKit"]),
        .library(name: "PCSC", targets: ["PCSC"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-log.git",
            .upToNextMajor(from: "1.6.1")
        ),
        .package(
            url: "https://github.com/unistash-io/swift-essentials.git",
            .upToNextMajor(from: "0.0.1")
        ),
        .package(
            url: "https://github.com/unistash-io/swift-essentials-nfc.git",
            .upToNextMajor(from: "0.0.1")
        ),
    ],
    targets: [
        .target(
            name: "PCSCKit",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Essentials", package: "swift-essentials"),
                .product(name: "EssentialsNFC", package: "swift-essentials-nfc"),
                .byName(name: "PCSC", condition: .when(platforms: [.macOS, .linux])),
            ],
            path: "Sources/PCSCKit"
        ),
        .target(
            name: "PCSC",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Essentials", package: "swift-essentials"),
                .byName(name: "Clibpcsclite"),
            ],
            path: "Sources/PCSC"
        ),
        .target(
            name: "Clibpcsclite",
            dependencies: [
                .byNameItem(name: "libpcsclite", condition: .when(platforms: [.linux])),
            ],
            path: "Sources/Clibpcsclite"
        ),
        .systemLibrary(
            name: "libpcsclite",
            pkgConfig: "libpcsclite",
            providers: [
                .apt(["libpcsclite-dev"]),
            ]
        ),
    ]
)
