public protocol UpdateOpenAIConfigurationUseCaseProtocol {
    func execute(configuration: OpenAIConfiguration) async
}

public class UpdateOpenAIConfigurationUseCase: UpdateOpenAIConfigurationUseCaseProtocol {

    private let repository: OpenAIRepositoryProtocol

    public init(repository: OpenAIRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(configuration: OpenAIConfiguration) async {
        await repository.updateOpenAIConfiguration(configuration: configuration)
    }
}
