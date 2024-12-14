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
    let container: DIContainer = DIContainer()
    
    var body: some Scene {
        WindowGroup {
            let viewModel = SplashViewModel(diContainer: container)
            SplashView(viewModel: viewModel)
        }
    }
}
