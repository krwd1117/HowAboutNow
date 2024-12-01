//
//  HowAboutNowApp.swift
//  HowAboutNow
//
//  Created by Jeongwan Kim on 11/29/24.
//

import SwiftUI
import Presentation

import FirebaseCore
import FirebaseFirestore
import FirebaseAuth


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct HowAboutNowApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
