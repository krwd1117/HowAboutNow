import Domain

public protocol DIContainerProtocol {
//    var diaryRepository: DiaryRepositoryProtocol { get }
    var addDiaryUseCase: AddDiaryUseCase { get }
    var analysisDiaryUseCase: AnalysisDiaryUseCase { get }
    var fetchDiaryUseCase: FetchDiaryUseCase { get }
    var deleteDiaryUseCase: DeleteDiaryUseCase { get }
    var updateDiaryUseCase: UpdateDiaryUseCase { get }
}
