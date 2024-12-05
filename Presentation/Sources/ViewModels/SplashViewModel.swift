import Foundation
import Domain

@MainActor
public final class SplashViewModel: ObservableObject {
    @Published public private(set) var isInitialized = false
    @Published public private(set) var error: Error?
    
    public private(set) var repository: DiaryRepository?
    public private(set) var diaryAnalysisService: DiaryAnalysisService?
    
    private let repositoryProvider: () -> DiaryRepository
    private let serviceProvider: () throws -> DiaryAnalysisService
    
    public init(
        repositoryProvider: @escaping () -> DiaryRepository,
        serviceProvider: @escaping () throws -> DiaryAnalysisService
    ) {
        self.repositoryProvider = repositoryProvider
        self.serviceProvider = serviceProvider
    }
    
    public func initializeServices() async {
        do {
            // Initialize services
            let repository = repositoryProvider()
            let analysisService = try serviceProvider()
            
            // Pre-fetch data
            _ = try await repository.getDiaries()
            
            // Store services
            self.repository = repository
            self.diaryAnalysisService = analysisService
            
            self.isInitialized = true
            self.error = nil
        } catch {
            self.error = error
            self.isInitialized = false
        }
    }
}
