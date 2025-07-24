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
            targets: ["KYCFormComposition"]
        ),
        .library(
            name: "KYCFormUI",
            targets: ["KYCFormUI"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "6.0.2")
    ],
    targets: [
        // MARK: - Core Layer (Domain)
        .target(
            name: "KYCFormCore",
            dependencies: [],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "KYCFormCoreTests",
            dependencies: ["KYCFormCore"]
        ),
        
        // MARK: - Infrastructure Layer
        .target(
            name: "KYCFormInfrastructure",
            dependencies: [
                "KYCFormCore",
                .product(name: "Yams", package: "Yams")
            ],
            resources: [
                .process("Resources") // Main app resources (e.g., nl.yaml)
            ]
        ),
        .testTarget(
            name: "KYCFormInfrastructureTests",
            dependencies: ["KYCFormInfrastructure"]
        ),
        
        // MARK: - Presentation Layer (ViewModels)
        .target(
            name: "KYCFormPresentation",
            dependencies: ["KYCFormCore", "KYCFormInfrastructure"]
        ),
        .testTarget(
            name: "KYCFormPresentationTests",
            dependencies: ["KYCFormPresentation"]
        ),
        
        // MARK: - UI Layer (Views)
        .target(
            name: "KYCFormUI",
            dependencies: ["KYCFormPresentation"]
        ),
        
        // MARK: - Composition Layer
        .target(
            name: "KYCFormComposition",
            dependencies: [
                "KYCFormCore",
                "KYCFormInfrastructure",
                "KYCFormPresentation",
                "KYCFormUI"
            ]
        )
    ]
)
