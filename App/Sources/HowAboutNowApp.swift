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

@main
struct HowAboutNowApp: App {
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
