import ProjectDescription

let project = Project(
    name: "HowAboutNow",
    organizationName: "HowAboutNow",
    packages: [
        .remote(url: "https://github.com/Alamofire/Alamofire.git", requirement: .upToNextMajor(from: "5.8.1")),
        .remote(url: "https://github.com/firebase/firebase-ios-sdk.git", requirement: .upToNextMajor(from: "10.0.0")),
    ],
    settings: .settings(
        base: [
            "IPHONEOS_DEPLOYMENT_TARGET": "17.0",
            "SWIFT_INSTALL_OBJC_HEADER": "YES",
            "SWIFT_OBJC_INTERFACE_HEADER_NAME": "$(PRODUCT_NAME)-Swift.h",
            "DEFINES_MODULE": "YES",
            "OTHER_LDFLAGS": "$(inherited) -ObjC"
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
                "UILaunchScreen": [
                    "UILaunchScreen": []
                ],
                "UIViewControllerBasedStatusBarAppearance": true,
                "UIStatusBarHidden": false,
                "UIRequiresFullScreen": false,
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
            resources: [
                "App/Resources/**"
            ],
            scripts: [
                .post(script: """
                    if [ "${CONFIGURATION}" = "Debug" ]; then
                        exit 0
                    fi
                    
                    CRASHLYTICS_PATH="${BUILD_DIR%Build/*}/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/upload-symbols"
                    
                    if [ ! -f "${CRASHLYTICS_PATH}" ]; then
                        echo "warning: Crashlytics upload-symbols not found at ${CRASHLYTICS_PATH}"
                        exit 0
                    fi
                    
                    "${CRASHLYTICS_PATH}" -gsp "${SRCROOT}/App/Resources/GoogleService-Info.plist" -p ios "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}"
                    """, name: "Upload Crashlytics Symbols")
            ],
            dependencies: [
                .target(name: "Domain"),
                .target(name: "Data"),
                .target(name: "Presentation"),
                .target(name: "Infrastructure"),
                .package(product: "FirebaseAnalytics"),
                .package(product: "FirebaseCrashlytics"),
            ]
        ),
        
        // MARK: - Domain Module
        .target(
            name: "Domain",
            destinations: [.iPhone],
            product: .framework,
            bundleId: "com.krwd.howaboutnow.domain",
            infoPlist: .default,
            sources: [
                "Domain/Sources/**"
            ],
            dependencies: [],
            settings: .settings(
                base: [
                    "DEFINES_MODULE": "YES"
                ]
            )
        ),
        
        // MARK: - Data Module
        .target(
            name: "Data",
            destinations: [.iPhone],
            product: .framework,
            bundleId: "com.krwd.howaboutnow.data",
            infoPlist: .default,
            sources: [
                "Data/Sources/**"
            ],
            dependencies: [
                .target(name: "Domain"),
                .target(name: "Infrastructure")
            ],
            settings: .settings(
                base: [
                    "DEFINES_MODULE": "YES"
                ]
            )
        ),
        
        // MARK: - Presentation Module
        .target(
            name: "Presentation",
            destinations: [.iPhone],
            product: .framework,
            bundleId: "com.krwd.howaboutnow.presentation",
            infoPlist: .default,
            sources: [
                "Presentation/Sources/**"
            ],
            dependencies: [
                .target(name: "Domain")
            ],
            settings: .settings(
                base: [
                    "DEFINES_MODULE": "YES"
                ]
            )
        ),
        
        // MARK: - Infrastructure Module
        .target(
            name: "Infrastructure",
            destinations: [.iPhone],
            product: .framework,
            bundleId: "com.krwd.howaboutnow.infrastructure",
            infoPlist: .default,
            sources: [
                "Infrastructure/Sources/**"
            ],
            dependencies: [
                .package(product: "Alamofire")
            ],
            settings: .settings(
                base: [
                    "DEFINES_MODULE": "YES"
                ]
            )
        )
    ]
)
