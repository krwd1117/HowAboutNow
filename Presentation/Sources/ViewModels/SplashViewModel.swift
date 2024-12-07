import Foundation
import Domain

public final class SplashViewModel: ObservableObject {
    @Published public private(set) var isInitialized = false
    @Published public private(set) var error: Error?
    
    public private(set) var repository: DiaryRepository?
    public private(set) var diaryAnalysisService: DiaryAnalysisService?
    public private(set) var initialDiaries: [Diary]?
    
    private let repositoryProvider: () -> DiaryRepository
    private let serviceProvider: () throws -> DiaryAnalysisService
    
    public nonisolated init(
        repositoryProvider: @escaping () -> DiaryRepository,
        serviceProvider: @escaping () throws -> DiaryAnalysisService
    ) {
        self.repositoryProvider = repositoryProvider
        self.serviceProvider = serviceProvider
    }
    
    @MainActor
    public func initializeServices() async {
        do {
            // Initialize services
            let repository = repositoryProvider()
            let analysisService = try serviceProvider()
            
            // Pre-fetch data
            let diaries = try await repository.getDiaries()
            
            // Store services and data
            self.repository = repository
            self.diaryAnalysisService = analysisService
            self.initialDiaries = diaries
            
            self.isInitialized = true
            self.error = nil
        } catch {
            self.error = error
            self.isInitialized = false
        }
    }
}
