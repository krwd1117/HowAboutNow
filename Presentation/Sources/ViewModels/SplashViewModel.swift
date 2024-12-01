import Foundation
import Domain
import Data
import Infrastructure

@MainActor
public final class SplashViewModel: ObservableObject {
    @Published private(set) var isInitialized = false
    @Published private(set) var error: Error?
    
    private(set) var repository: DiaryRepository?
    private(set) var emotionAnalysisService: EmotionAnalysisService?
    private(set) var contentSummaryService: ContentSummaryService?
    
    public init() {}
    
    public func initializeServices() async {
        do {
            let apiKey = try ConfigurationManager.shared.string(for: ConfigurationManager.Keys.openAIAPIKey)
            
            // Initialize services
            let repository = DiaryDataRepository()
            let emotionService = OpenAIEmotionAnalysisService(apiKey: apiKey)
            let summaryService = OpenAIContentSummaryService(apiKey: apiKey)
            
            // Pre-fetch data
            Logger.d("Pre-fetching diaries...")
            _ = try await repository.getDiaries()
            
            // Store services
            self.repository = repository
            self.emotionAnalysisService = emotionService
            self.contentSummaryService = summaryService
            
            self.isInitialized = true
            self.error = nil
        } catch {
            Logger.e("Failed to initialize services: \(error)")
            self.error = error
            self.isInitialized = false
        }
    }
}
