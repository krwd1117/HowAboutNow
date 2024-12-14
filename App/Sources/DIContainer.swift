import Foundation
import Domain
import Data
import Presentation

public final class DIContainer: DIContainerProtocol {
    public static let shared = DIContainer()
    
    // MARK: - Repositories
    private let diaryRepository: DiaryRepositoryProtocol
    private let openAIRepository: OpenAIRepositoryProtocol

    // MARK: - Use Cases
    public let addDiaryUseCase: AddDiaryUseCase
    public let analysisDiaryUseCase: AnalysisDiaryUseCase
    public let fetchDiaryUseCase: FetchDiaryUseCase
    public let deleteDiaryUseCase: DeleteDiaryUseCase
    public let updateDiaryUseCase: UpdateDiaryUseCase

    // MARK: - Initializer
    init() {
        // Data 계층 Repository 설정
        self.diaryRepository = DiaryRepository()
        self.openAIRepository = OpenAIRepository(openAIService: OpenAIService())

        // UseCase 의존성 주입
        addDiaryUseCase = AddDiaryUseCase(repository: diaryRepository)
        deleteDiaryUseCase = DeleteDiaryUseCase(repository: diaryRepository)
        fetchDiaryUseCase = FetchDiaryUseCase(repository: diaryRepository)
        updateDiaryUseCase = UpdateDiaryUseCase(repository: diaryRepository)
        
        analysisDiaryUseCase = AnalysisDiaryUseCase(repository: openAIRepository)
    }
}
