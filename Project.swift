import ProjectDescription

let destinations: Destinations = .iOS
let deploymentTarget: DeploymentTargets = .iOS("17.0")

let project = Project(
    name: "HowAboutNow",
    organizationName: "HowAboutNow",
    options: .options(
        automaticSchemesOptions: .enabled(
            targetSchemesGrouping: .byNameSuffix(build: ["HowAboutNow"], test: [], run: ["HowAboutNow"]),
            codeCoverageEnabled: true,
            testingOptions: .parallelizable
        )
    ),
    packages: [
        .remote(url: "https://github.com/Alamofire/Alamofire.git", requirement: .upToNextMajor(from: "5.8.1")),
    ],
    settings: .settings(
        base: [:],
        configurations: [
            .debug(name: "Debug"),
            .release(name: "Release")
        ],
        defaultSettings: .recommended
    ),
    targets: [
        .target(
            name: "HowAboutNow",
            destinations: destinations,
            product: .app,
            bundleId: "com.krwd.howaboutnow.app",
            deploymentTargets: deploymentTarget,
            infoPlist: .extendingDefault(with: [
                "UILaunchScreen": [
                    "UILaunchScreen": []
                ],
                "UIViewControllerBasedStatusBarAppearance": false,
                "UIStatusBarHidden": false,
                "UIRequiresFullScreen": true
            ]),
            sources: ["App/Sources/**"],
            resources: ["App/Resources/**", "App/Resources/NewResource"],
            entitlements: .file(path: "App/Resources/HowAboutNow.entitlements"),
            dependencies: [
                .target(name: "Core"),
                .target(name: "Feature"),
                .target(name: "UI")
            ]
        ),
        
        .target(
            name: "Core",
            destinations: destinations,
            product: .framework,
            bundleId: "com.krwd.howaboutnow.core",
            deploymentTargets: deploymentTarget,
            infoPlist: .default,
            sources: ["Core/Sources/**"],
            dependencies: [
                .package(product: "Alamofire"),
            ]
        ),
        
        .target(
            name: "Feature",
            destinations: destinations,
            product: .framework,
            bundleId: "com.krwd.howaboutnow.feature",
            deploymentTargets: deploymentTarget,
            infoPlist: .default,
            sources: ["Feature/Sources/**"],
            dependencies: [
                .target(name: "Core"),
                .target(name: "UI")
            ]
        ),
        
        .target(
            name: "UI",
            destinations: destinations,
            product: .framework,
            bundleId: "com.krwd.howaboutnow.ui",
            deploymentTargets: deploymentTarget,
            infoPlist: .default,
            sources: ["UI/Sources/**"],
            dependencies: [
                .target(name: "Core")
            ]
        )
    ]
)
