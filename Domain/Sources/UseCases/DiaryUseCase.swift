import Foundation

public actor DiaryUseCase {
    private let repository: DiaryRepository
    private let diaryAnalysisService: DiaryAnalysisService
    
    public init(repository: DiaryRepository,
               diaryAnalysisService: DiaryAnalysisService) {
        self.repository = repository
        self.diaryAnalysisService = diaryAnalysisService
    }
    
    public func getDiaries() async throws -> [Diary] {
        try await repository.getDiaries()
    }
    
    public func saveDiary(_ diary: Diary) async throws {
        let analysis = try await diaryAnalysisService.analyzeDiary(content: diary.content)
        let analyzedDiary = Diary(
            id: diary.id,
            title: diary.title,
            content: diary.content,
            emotion: analysis.emotion,
            summary: analysis.summary,
            date: diary.date
        )
        try await repository.saveDiary(analyzedDiary)
    }
    
    public func updateDiary(_ diary: Diary) async throws {
        let analysis = try await diaryAnalysisService.analyzeDiary(content: diary.content)
        let analyzedDiary = Diary(
            id: diary.id,
            title: diary.title,
            content: diary.content,
            emotion: analysis.emotion,
            summary: analysis.summary,
            date: diary.date
        )
        try await repository.updateDiary(analyzedDiary)
    }
    
    public func deleteDiary(_ diary: Diary) async throws {
        try await repository.deleteDiary(diary)
    }
}
