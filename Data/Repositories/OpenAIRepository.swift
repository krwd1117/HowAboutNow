import Foundation
import Domain

public final class OpenAIRepository: OpenAIRepositoryProtocol {
    private let openAIService: OpenAIServiceProtocol
    
    // 의존성 주입을 위한 생성자
    public init(openAIService: OpenAIServiceProtocol) {
        self.openAIService = openAIService
    }
    
    public func analyzeDiary(diary: Diary) async throws -> DiaryAnalysis {
        let diaryAnalysis = try await openAIService.analyzeDiary(content: diary.content)
        return diaryAnalysis
    }

    public func updateOpenAIConfiguration(configuration: OpenAIConfiguration) async {
        await openAIService.updateOpenAIConfiguration(configuration: configuration)
    }
}
