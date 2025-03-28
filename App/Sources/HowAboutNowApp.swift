//
//  HowAboutNowApp.swift
//  HowAboutNow
//
//  Created by Jeongwan Kim on 11/29/24.
//

import SwiftUI
import Firebase
import FirebaseCrashlytics

import Data
import DI
import Domain
import Presentation

@main
struct HowAboutNowApp: App {
    
    @State var isDIInitialized: Bool = false
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if isDIInitialized {
                let viewModel = SplashViewModel()
                SplashView(viewModel: viewModel)
            } else {
                Text("Loading..")
                    .task {
                        await DIContainer.shared.initialize()
                        self.isDIInitialized = true
                    }
            }
        }
    }
}
