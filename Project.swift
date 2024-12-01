import ProjectDescription

let project = Project(
    name: "HowAboutNow",
    organizationName: "HowAboutNow",
    packages: [
        .remote(url: "https://github.com/firebase/firebase-ios-sdk.git", requirement: .upToNextMajor(from: "10.19.1")),
        .remote(url: "https://github.com/google/abseil-cpp-binary.git", requirement: .upToNextMajor(from: "1.2024011601.0")),
        .remote(url: "https://github.com/apple/swift-protobuf.git", requirement: .upToNextMajor(from: "1.25.2")),
        .remote(url: "https://github.com/Alamofire/Alamofire.git", requirement: .upToNextMajor(from: "5.8.1"))
    ],
    settings: .settings(
        base: [
            "IPHONEOS_DEPLOYMENT_TARGET": "17.0"
        ],
        configurations: [
            .debug(name: "Debug"),
            .release(name: "Release")
        ]
    ),
    targets: [
        // MARK: - App Module
        /// 앱의 진입점 모듈
        /// - 앱의 생명주기 관리
        /// - 의존성 주입 설정
        /// - 메인 네비게이션 흐름
        /// - 리소스 파일 관리 (Assets, Plist 등)
        .target(
            name: "App",
            destinations: [.iPhone],
            product: .app,
            bundleId: "com.krwd.howaboutnow.app",
            infoPlist: .extendingDefault(with: [
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
                .post(
                    script: """
                    ${BUILD_DIR%/Build/*}/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/run
                    """,
                    name: "Firebase Crashlytics"
                )
            ],
            dependencies: [
                .target(name: "Domain"),
                .target(name: "Data"),
                .target(name: "Presentation"),
                .target(name: "Infrastructure"),
                .package(product: "FirebaseAnalytics"),
                .package(product: "FirebaseAuthCombine-Community"),
                .package(product: "FirebaseFirestore"),
                .package(product: "FirebaseFirestoreCombine-Community"),
                .package(product: "FirebaseStorage"),
                .package(product: "FirebaseMessaging"),
                .package(product: "FirebaseCrashlytics"),
                .package(product: "SwiftProtobuf")
            ]
        ),
        
        // MARK: - Domain Module
        /// 비즈니스 로직의 핵심 모듈 (가장 안쪽 레이어)
        /// - Entities (비즈니스 모델)
        /// - Use Cases (비즈니스 로직)
        /// - Repository Interfaces
        /// - 외부 의존성이 전혀 없는 순수한 Swift 코드
        .target(
            name: "Domain",
            destinations: [.iPhone],
            product: .framework,
            bundleId: "com.krwd.howaboutnow.domain",
            infoPlist: .default,
            sources: ["Domain/Sources/**"]
        ),
        
        // MARK: - Data Module
        /// 데이터 계층 모듈
        /// - Repository Implementations
        /// - API/Network Services
        /// - Local Storage
        /// - DTO (Data Transfer Objects)
        /// - Domain 레이어의 인터페이스를 구현
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
        /// UI 표현 계층 모듈
        /// - ViewModels/Presenters
        /// - Views/UI Components
        /// - State Management
        /// - Navigation Logic
        /// - Domain 레이어의 Use Cases를 사용
        .target(
            name: "Presentation",
            destinations: [.iPhone],
            product: .framework,
            bundleId: "com.krwd.howaboutnow.presentation",
            infoPlist: .default,
            sources: ["Presentation/Sources/**"],
            dependencies: [
                .target(name: "Domain"),
                .target(name: "Infrastructure")
            ]
        ),
        
        // MARK: - Infrastructure Module
        /// 인프라스트럭처 계층 모듈 (가장 바깥쪽 레이어)
        /// - DI Container
        /// - System Services
        /// - Third-party Integrations
        /// - Configuration
        /// - Logging
        /// - Common Utilities
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
