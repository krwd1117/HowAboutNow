// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "HowAboutNow",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Domain",
            targets: ["Domain"]
        ),
        .library(
            name: "Data",
            targets: ["Data"]
        ),
        .library(
            name: "Presentation",
            targets: ["Presentation"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/MacPaw/OpenAI.git", .upToNextMajor(from: "0.2.4"))
    ],
    targets: [
        .target(
            name: "Domain",
            dependencies: [],
            path: "Domain/Sources"
        ),
        .target(
            name: "Data",
            dependencies: [
                "Domain",
                .product(name: "OpenAI", package: "OpenAI")
            ],
            path: "Data/Sources"
        ),
        .target(
            name: "Presentation",
            dependencies: [
                "Domain",
                "Data"
            ],
            path: "Presentation/Sources"
        ),
        .testTarget(
            name: "DomainTests",
            dependencies: ["Domain"],
            path: "Domain/Tests"
        ),
        .testTarget(
            name: "DataTests",
            dependencies: ["Data"],
            path: "Data/Tests"
        ),
        .testTarget(
            name: "PresentationTests",
            dependencies: ["Presentation"],
            path: "Presentation/Tests"
        )
    ]
)
