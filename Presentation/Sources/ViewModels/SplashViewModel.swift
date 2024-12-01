import Foundation
import Domain
import Data
import Infrastructure

@MainActor
public final class SplashViewModel: ObservableObject {
    @Published private(set) var isInitialized = false
    @Published private(set) var error: Error?
    
    private(set) var repository: DiaryRepository?
    private(set) var diaryAnalysisService: DiaryAnalysisService?
    
    public init() {}
    
    public func initializeServices() async {
        do {
            // Initialize services
            let repository = DiaryDataRepository()
            let analysisService = try OpenAIDiaryAnalysisService()
            
            // Pre-fetch data
            Logger.d("Pre-fetching diaries...")
            _ = try await repository.getDiaries()
            
            // Store services
            self.repository = repository
            self.diaryAnalysisService = analysisService
            
            self.isInitialized = true
            self.error = nil
        } catch {
            Logger.e("Failed to initialize services: \(error)")
            self.error = error
            self.isInitialized = false
        }
    }
}
