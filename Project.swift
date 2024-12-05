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
                    
                    # dSYM 파일 찾기
                    DSYM_PATH="${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}"
                    if [ ! -d "$DSYM_PATH" ]; then
                        echo "warning: dSYM not found at ${DSYM_PATH}"
                        exit 0
                    fi
                    
                    # Crashlytics 업로드 도구 경로 설정
                    DERIVED_DATA_PATHS=(
                        "/Volumes/SSD/Library/Developer/Xcode/DerivedData"
                        "${HOME}/Library/Developer/Xcode/DerivedData"
                    )
                    
                    for DERIVED_DATA_PATH in "${DERIVED_DATA_PATHS[@]}"; do
                        if [ -d "${DERIVED_DATA_PATH}" ]; then
                            CRASHLYTICS_PATH=$(find "${DERIVED_DATA_PATH}" -path "*/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/upload-symbols" -type f | head -n 1)
                            if [ -f "${CRASHLYTICS_PATH}" ]; then
                                break
                            fi
                        fi
                    done
                    
                    if [ ! -f "${CRASHLYTICS_PATH}" ]; then
                        echo "warning: Crashlytics upload-symbols not found in any DerivedData directory"
                        exit 0
                    fi
                    
                    # Upload dSYM
                    "${CRASHLYTICS_PATH}" -gsp "${SRCROOT}/App/Resources/GoogleService-Info.plist" -p ios "${DSYM_PATH}"
                    """, name: "Upload Crashlytics Symbols", runOnlyWhenInstalling: true)
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
