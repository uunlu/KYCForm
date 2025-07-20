// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KYCForm",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "KYCForm",
            targets: ["KYCFormComposition"])
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "6.0.1")
    ],
    targets: [
        // Core
        .target(
            name: "KYCFormCore",
            dependencies: []),
        .testTarget(
            name: "KYCFormCoreTests",
            dependencies: ["KYCFormCore"]),
        
        // Infrastructure
        .target(
            name: "KYCFormInfrastructure",
            dependencies: [
                "KYCFormCore",
                .product(name: "Yams", package: "Yams")
            ],
            resources: [
                .process("Resources"),
                .process("TestResources")
            ]
        ),
        .testTarget(
            name: "KYCFormInfrastructureTests",
            dependencies: ["KYCFormInfrastructure"]),
        
        // Presentation
        .target(
            name: "KYCFormPresentation",
            dependencies: ["KYCFormCore", "KYCFormInfrastructure"]),
        .testTarget(
            name: "KYCFormPresentationTests",
            dependencies: ["KYCFormPresentation"]),
        
        // Composition
        .target(
            name: "KYCFormComposition",
            dependencies: [
                "KYCFormCore",
                "KYCFormInfrastructure",
                "KYCFormPresentation"
            ])
    ]
)
