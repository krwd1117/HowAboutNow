//
//  HowAboutNowApp.swift
//  HowAboutNow
//
//  Created by Jeongwan Kim on 11/29/24.
//

import SwiftUI
import Domain
import Data
import Presentation
import Firebase
import FirebaseCrashlytics

@main
struct HowAboutNowApp: App {
    @StateObject private var appCoordinator: AppCoordinator
    private let diContainer: DIContainerProtocol

    init() {
        FirebaseApp.configure()
        
        // DIContainer 초기화
        let diContainer = DIContainer()
        self.diContainer = diContainer

        // AppCoordinator 초기화
        self._appCoordinator = StateObject(wrappedValue: AppCoordinator(diContainer: diContainer))
    }

    var body: some Scene {
        WindowGroup {
            Group {
                switch appCoordinator.currentView {
                case .splash:
                    let viewModel = SplashViewModel(diContainer: diContainer)
                    SplashView(viewModel: viewModel)
                        .environmentObject(appCoordinator)
                case .mainTab:
                    BottomTabView(diContainer: diContainer)
                        .environmentObject(BottomTabCoordinator(diContainer: diContainer))
                }
            }
        }
    }
}
