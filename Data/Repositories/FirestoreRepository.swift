import Foundation
import Domain

public final class FirestoreRepository: FirestoreRepositoryProtocol {

    private let firestoreService: FirestoreServiceProtocol

    public init(firestoreService: FirestoreServiceProtocol) {
        self.firestoreService = firestoreService
    }

    public func fetchOpenAIConfiguration(collection: String, document: String) async throws -> OpenAIConfiguration {
        let response: OpenAIConfigurationResponse = try await firestoreService.fetchDocumentation(
            collection: collection,
            document: document
        )

        return OpenAIConfiguration(
            model: response.model,
            prompt: response.prompt,
            systemContent: response.systemContent,
            temperature: response.temperature
        )

    }
}
