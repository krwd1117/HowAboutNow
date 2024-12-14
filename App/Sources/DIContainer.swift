import Foundation
import Domain
import Data
import Presentation

public final class DIContainer: DIContainerProtocol {
    // MARK: - Repositories
    private let diaryRepository: DiaryRepositoryProtocol

    // MARK: - Use Cases
    public let addDiaryUseCase: AddDiaryUseCase
    public let analysisDiaryUseCase: AnalysisDiaryUseCase
    public let fetchDiaryUseCase: FetchDiaryUseCase
    public let deleteDiaryUseCase: DeleteDiaryUseCase
    public let updateDiaryUseCase: UpdateDiaryUseCase

    // MARK: - Initializer
    init() {
        // Data 계층 Repository 설정
        diaryRepository = DiaryRepository()

        // UseCase 의존성 주입
        addDiaryUseCase = AddDiaryUseCase(repository: diaryRepository)
        analysisDiaryUseCase = AnalysisDiaryUseCase(repository: diaryRepository)
        deleteDiaryUseCase = DeleteDiaryUseCase(repository: diaryRepository)
        fetchDiaryUseCase = FetchDiaryUseCase(repository: diaryRepository)
        updateDiaryUseCase = UpdateDiaryUseCase(repository: diaryRepository)
    }
}
