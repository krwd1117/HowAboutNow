import Foundation
import Domain

public final class SplashViewModel: ObservableObject {
    
    @Published public private(set) var isInitialized = false
    @Published public private(set) var error: Error?
    
    public private(set) var initialDiaries: [Diary]?
    
    let diContainer: DIContainerProtocol
    
//    private let repository: DiaryRepositoryProtocol
    
//    private(set) lazy var addDiaryUseCase: AddDiaryUseCaseProtocol = AddDiaryUseCase(repository: diContainer.diaryRepository)
//    private(set) lazy var deleteDiaryUseCase: DeleteDiaryUseCaseProtocol = DeleteDiaryUseCase(repository: diContainer.diaryRepository)
//    private(set) lazy var analysisDiaryUseCase: AnalysisDiaryUseCaseProtocol = AnalysisDiaryUseCase(repository: diContainer.diaryRepository)
//    private(set) lazy var fetchDiaryUseCase: FetchDiaryUseCaseProtocol = FetchDiaryUseCase(repository: diContainer.diaryRepository)
//    private(set) lazy var updateDairyUseCase: UpdateDiaryUseCaseProtocol = UpdateDiaryUseCase(repository: diContainer.diaryRepository)
    
    public init(diContainer: DIContainerProtocol) {
        self.diContainer = diContainer
    }
    
    @MainActor
    public func initializeServices() async {
        do {
            self.initialDiaries = try await diContainer.fetchDiaryUseCase.execute()
            
            self.isInitialized = true
            self.error = nil
        } catch {
            self.isInitialized = false
            self.error = error
        }
    }
}
