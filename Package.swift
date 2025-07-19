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
        // Dependencies declare other packages that this package depends on.
    ],
    targets: [
        // 1. Core Layer (Domain)
        .target(
            name: "KYCFormCore",
            dependencies: []),
        .testTarget(
            name: "KYCFormCoreTests",
            dependencies: ["KYCFormCore"]),
            
        // 2. Infrastructure Layer
        .target(
            name: "KYCFormInfrastructure",
            dependencies: ["KYCFormCore"]),
        .testTarget(
            name: "KYCFormInfrastructureTests",
            dependencies: ["KYCFormInfrastructure"]),
            
        // 3. Presentation Layer
        .target(
            name: "KYCFormPresentation",
            dependencies: ["KYCFormCore"]),
        .testTarget(
            name: "KYCFormPresentationTests",
            dependencies: ["KYCFormPresentation"]),
            
        // 4. Composition Layer
        .target(
            name: "KYCFormComposition",
            dependencies: [
                "KYCFormCore",
                "KYCFormInfrastructure",
                "KYCFormPresentation"
            ])
    ]
)
