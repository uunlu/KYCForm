// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KYCForm",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "KYCForm",
            targets: ["KYCFormComposition"])
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.0")
    ],
    targets: [
        .target(
            name: "KYCFormCore",
            dependencies: []),
        .testTarget(
            name: "KYCFormCoreTests",
            dependencies: ["KYCFormCore"]),
        
            .target(
                name: "KYCFormInfrastructure",
                dependencies: [
                    "KYCFormCore",
                    .product(name: "Yams", package: "Yams")
                ]),
        .target(
            name: "KYCFormInfrastructure",
            dependencies: [
                "KYCFormCore",
                .product(name: "Yams", package: "Yams")
            ],
            resources: [
                .process("Resources")
            ]
        ),
            .target(
                name: "KYCFormPresentation",
                dependencies: ["KYCFormCore"]),
        .testTarget(
            name: "KYCFormPresentationTests",
            dependencies: ["KYCFormPresentation"]),
        
            .target(
                name: "KYCFormComposition",
                dependencies: [
                    "KYCFormCore",
                    "KYCFormInfrastructure",
                    "KYCFormPresentation"
                ])
    ]
)
