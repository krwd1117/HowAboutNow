import Domain

public protocol DIContainerProtocol {
    var addDiaryUseCase: AddDiaryUseCase { get }
    var fetchDiaryUseCase: FetchDiaryUseCase { get }
    var deleteDiaryUseCase: DeleteDiaryUseCase { get }
    var updateDiaryUseCase: UpdateDiaryUseCase { get }
    
    var analysisDiaryUseCase: AnalysisDiaryUseCase { get }
    var updateOpenAIConfigurationUseCase: UpdateOpenAIConfigurationUseCase { get }

    var fetchOpenAIConfigurationUseCase: FetchOpenAIConfigurationUseCase { get }
}
