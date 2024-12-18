import Domain

public protocol DIContainerProtocol {
    var addDiaryUseCase: AddDiaryUseCase { get }
    var fetchDiariesUseCase: FetchDiariesUseCase { get }
    var fetchDiaryUseCase: FetchDiaryUseCase { get }
    var deleteDiaryUseCase: DeleteDiaryUseCase { get }
    var updateDiaryUseCase: UpdateDiaryUseCase { get }
    
    var analyzeDiaryUseCase: AnalyzeDiaryUseCase { get }
    var updateOpenAIConfigurationUseCase: UpdateOpenAIConfigurationUseCase { get }

    var fetchOpenAIConfigurationUseCase: FetchOpenAIConfigurationUseCase { get }
}
