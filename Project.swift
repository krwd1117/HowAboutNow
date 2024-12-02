import ProjectDescription

let project = Project(
    name: "HowAboutNow",
    organizationName: "HowAboutNow",
    packages: [
        .remote(url: "https://github.com/Alamofire/Alamofire.git", requirement: .upToNextMajor(from: "5.8.1"))
    ],
    settings: .settings(
        base: [
            "IPHONEOS_DEPLOYMENT_TARGET": "17.0",
            "SWIFT_INSTALL_OBJC_HEADER": "YES",
            "SWIFT_OBJC_INTERFACE_HEADER_NAME": "$(PRODUCT_NAME)-Swift.h",
            "DEFINES_MODULE": "YES"
        ],
        configurations: [
            .debug(name: "Debug", settings: [:], xcconfig: nil),
            .release(name: "Release", settings: [:], xcconfig: nil)
        ]
    ),
    targets: [
        // MARK: - App Module
        .target(
            name: "HowAboutNow",
            destinations: [.iPhone],
            product: .app,
            bundleId: "com.krwd.howaboutnow.app",
            infoPlist: .extendingDefault(with: [
                "CFBundleDisplayName": "나의 매일",
                "CFBundleIconName": "AppIcon",
                "UILaunchScreen": ["UILaunchScreen": []],
                "UIViewControllerBasedStatusBarAppearance": true,
                "UIStatusBarHidden": false,
                "UIRequiresFullScreen": true,
                "ITSAppUsesNonExemptEncryption": false,
                "LSRequiresIPhoneOS": true,
                "CFBundleDevelopmentRegion": "en",
                "CFBundleLocalizations": ["en", "ko", "ja", "zh"],
                "UIApplicationSceneManifest": [
                    "UIApplicationSupportsMultipleScenes": false,
                    "UISceneConfigurations": [:]
                ]
            ]),
            sources: ["App/Sources/**"],
            resources: ["App/Resources/**"],
            dependencies: [
                .target(name: "Domain"),
                .target(name: "Data"),
                .target(name: "Presentation"),
                .target(name: "Infrastructure")
            ]
        ),
        
        // MARK: - Domain Module
        .target(
            name: "Domain",
            destinations: [.iPhone],
            product: .framework,
            bundleId: "com.krwd.howaboutnow.domain",
            infoPlist: .default,
            sources: ["Domain/Sources/**"],
            dependencies: []
        ),
        
        // MARK: - Data Module
        .target(
            name: "Data",
            destinations: [.iPhone],
            product: .framework,
            bundleId: "com.krwd.howaboutnow.data",
            infoPlist: .default,
            sources: ["Data/Sources/**"],
            dependencies: [
                .target(name: "Domain"),
                .target(name: "Infrastructure")
            ]
        ),
        
        // MARK: - Presentation Module
        .target(
            name: "Presentation",
            destinations: [.iPhone],
            product: .framework,
            bundleId: "com.krwd.howaboutnow.presentation",
            infoPlist: .default,
            sources: ["Presentation/Sources/**"],
            dependencies: [
                .target(name: "Domain")
            ]
        ),
        
        // MARK: - Infrastructure Module
        .target(
            name: "Infrastructure",
            destinations: [.iPhone],
            product: .framework,
            bundleId: "com.krwd.howaboutnow.infrastructure",
            infoPlist: .default,
            sources: ["Infrastructure/Sources/**"],
            dependencies: [
                .package(product: "Alamofire")
            ]
        )
    ]
)
