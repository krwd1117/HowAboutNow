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
import FirebaseCore
import FirebaseMessaging
import FirebaseCrashlytics

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        #if DEBUG
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(false)
        #else
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
        #endif
        
        return true
    }
}

@main
struct HowAboutNowApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
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
