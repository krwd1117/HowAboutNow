public protocol AnalyzeDiaryUseCaseProtocol {
    func excute(diary: Diary) async throws -> DiaryAnalysis?
}

public final class AnalyzeDiaryUseCase: AnalyzeDiaryUseCaseProtocol {
    let repository: OpenAIRepositoryProtocol
    
    public init(repository: OpenAIRepositoryProtocol) {
        self.repository = repository
    }
    
    public func excute(diary: Diary) async throws -> DiaryAnalysis? {
        let diaryAnalysis = try await repository.analyzeDiary(diary: diary)
        return diaryAnalysis
    }
}
