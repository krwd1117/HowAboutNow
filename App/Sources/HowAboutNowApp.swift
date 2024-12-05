//
//  HowAboutNowApp.swift
//  HowAboutNow
//
//  Created by Jeongwan Kim on 11/29/24.
//

import SwiftUI
import Domain
import Data
import Infrastructure
import Presentation
import Firebase
import FirebaseCrashlytics

@main
struct HowAboutNowApp: App {
    init() {
        FirebaseApp.configure()
//        fatalError("Firebase Crashlytics")
    }
    
    var body: some Scene {
        WindowGroup {
            SplashView(
                repositoryProvider: {
                    DiaryDataRepository()
                },
                serviceProvider: {
                    try OpenAIDiaryAnalysisService()
                }
            )
            .preferredColorScheme(.light)
            .tint(.purple)
        }
    }
}
