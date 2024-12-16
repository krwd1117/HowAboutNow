public protocol FirestoreRepositoryProtocol {
    func fetchOpenAIConfiguration(collection: String, document: String) async throws -> OpenAIConfiguration
}
