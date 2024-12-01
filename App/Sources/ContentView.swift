import SwiftUI
import Presentation
import Data
import Domain
import Infrastructure

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

struct ContentView: View {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    private let repository: DiaryRepository
    private let emotionAnalysisService: EmotionAnalysisService
    
    init() {
        do {
            let OPEN_AI_API_KEY = try ConfigurationManager.shared.string(for: ConfigurationManager.Keys.openAIAPIKey)
            
            repository = try DiaryDataRepository()
            emotionAnalysisService = OpenAIEmotionAnalysisService(apiKey: OPEN_AI_API_KEY)
        } catch {
            fatalError("Failed to initialize: \(error)")
        }
    }
    
    var body: some View {
        MainTabView(repository: repository, emotionAnalysisService: emotionAnalysisService)
            .preferredColorScheme(.light)
            .tint(.pink)
    }
}
