public protocol OpenAIRepositoryProtocol {
    func analyzeDiary(diary: Diary) async throws -> DiaryAnalysis
}
