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
    packages: [],
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
            resources: ["App/Resources/**"],
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
            dependencies: []
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
    ],
    schemes: [
        .scheme(
            name: "HowAboutNow",
            shared: true,
            buildAction: .buildAction(targets: ["HowAboutNow"]),
            testAction: nil,
            runAction: .runAction(configuration: "Debug"),
            archiveAction: .archiveAction(configuration: "Release"),
            profileAction: .profileAction(configuration: "Release"),
            analyzeAction: .analyzeAction(configuration: "Debug")
        ),
        .scheme(
            name: "Core",
            shared: true,
            buildAction: .buildAction(targets: ["Core"]),
            testAction: nil,
            runAction: nil,
            archiveAction: .archiveAction(configuration: "Release"),
            profileAction: .profileAction(configuration: "Release"),
            analyzeAction: .analyzeAction(configuration: "Debug")
        ),
        .scheme(
            name: "Feature",
            shared: true,
            buildAction: .buildAction(targets: ["Feature"]),
            testAction: nil,
            runAction: nil,
            archiveAction: .archiveAction(configuration: "Release"),
            profileAction: .profileAction(configuration: "Release"),
            analyzeAction: .analyzeAction(configuration: "Debug")
        ),
        .scheme(
            name: "UI",
            shared: true,
            buildAction: .buildAction(targets: ["UI"]),
            testAction: nil,
            runAction: nil,
            archiveAction: .archiveAction(configuration: "Release"),
            profileAction: .profileAction(configuration: "Release"),
            analyzeAction: .analyzeAction(configuration: "Debug")
        )
    ]
)
