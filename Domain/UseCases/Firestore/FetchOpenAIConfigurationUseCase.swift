import Foundation

public protocol FetchOpenAIConfigurationUseCaseProtocol {
    func execute(collection: String, document: String) async throws -> OpenAIConfiguration
}

public final class FetchOpenAIConfigurationUseCase: FetchOpenAIConfigurationUseCaseProtocol {

    private let repository: FirestoreRepositoryProtocol

    public init(repository: FirestoreRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(collection: String, document: String) async throws -> OpenAIConfiguration {
        try await repository.fetchOpenAIConfiguration(collection: collection, document: document)
    }
}
