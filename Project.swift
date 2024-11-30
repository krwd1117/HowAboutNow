import ProjectDescription

let destinations: Destinations = .iOS
let deploymentTargets: DeploymentTargets = .iOS("17.0")

let baseSettings: SettingsDictionary = [
    "ENABLE_BITCODE": "NO",
    "SWIFT_EMIT_MODULE_INTERFACE": "NO",
    "IPHONEOS_DEPLOYMENT_TARGET": "17.0",
    "TARGETED_DEVICE_FAMILY": "1",  // iPhone only
    "SWIFT_VERSION": "5.0",
    "DEVELOPMENT_TEAM": "",  // Add your team ID here if needed
    "CODE_SIGN_STYLE": "Automatic",
    "SWIFT_STRICT_CONCURRENCY": "complete",
    "ENABLE_USER_SCRIPT_SANDBOXING": "YES",
    "GCC_TREAT_WARNINGS_AS_ERRORS": "YES"
]

let project = Project(
    name: "HowAboutNow",
    organizationName: "HowAboutNow",
    options: .options(
        automaticSchemesOptions: .enabled(
            targetSchemesGrouping: .byNameSuffix(build: ["HowAboutNow"], test: [], run: ["HowAboutNow"]),
            codeCoverageEnabled: true,
            testingOptions: .parallelizable
        ),
        disableBundleAccessors: false,
        disableShowEnvironmentVarsInScriptPhases: true,
        disableSynthesizedResourceAccessors: false
    ),
    packages: [
        .remote(url: "https://github.com/Alamofire/Alamofire.git", requirement: .upToNextMajor(from: "5.8.1")),
    ],
    settings: .settings(
        base: baseSettings,
        configurations: [
            .debug(name: "Debug", settings: [
                "SWIFT_OPTIMIZATION_LEVEL": "-Onone",
                "DEBUG_INFORMATION_FORMAT": "dwarf",
                "ENABLE_TESTABILITY": "YES",
                "GCC_OPTIMIZATION_LEVEL": "0",
                "ONLY_ACTIVE_ARCH": "YES"
            ]),
            .release(name: "Release", settings: [
                "SWIFT_OPTIMIZATION_LEVEL": "-O",
                "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
                "ENABLE_NS_ASSERTIONS": "NO",
                "SWIFT_COMPILATION_MODE": "wholemodule"
            ])
        ],
        defaultSettings: .recommended
    ),
    targets: [
        .target(
            name: "HowAboutNow",
            destinations: destinations,
            product: .app,
            bundleId: "com.krwd.howaboutnow.app",
            deploymentTargets: deploymentTargets,
            infoPlist: .extendingDefault(with: [
                "UILaunchScreen": [
                    "UILaunchScreen": []
                ],
                "UIViewControllerBasedStatusBarAppearance": false,
                "UIStatusBarHidden": false,
                "UIRequiresFullScreen": true,
                "ITSAppUsesNonExemptEncryption": false,
                "LSRequiresIPhoneOS": true,
                "UIApplicationSceneManifest": [
                    "UIApplicationSupportsMultipleScenes": false,
                    "UISceneConfigurations": [:]
                ]
            ]),
            sources: ["App/Sources/**"],
            resources: [
                .glob(pattern: "App/Resources/*", excluding: ["App/Resources/HowAboutNow.entitlements"])
            ],
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
            deploymentTargets: deploymentTargets,
            sources: ["Core/Sources/**"],
            dependencies: [
                .package(product: "Alamofire")
            ]
        ),
        .target(
            name: "Feature",
            destinations: destinations,
            product: .framework,
            bundleId: "com.krwd.howaboutnow.feature",
            deploymentTargets: deploymentTargets,
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
            deploymentTargets: deploymentTargets,
            sources: ["UI/Sources/**"],
            dependencies: [
                .target(name: "Core")
            ]
        )
    ]
)
