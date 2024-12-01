import Foundation

public protocol DiaryUseCase {
    func createDiary(_ diary: Diary) async throws
    func updateDiary(_ diary: Diary) async throws
    func deleteDiary(_ diary: Diary) async throws
    func getDiaries() async throws -> [Diary]
    func analyzeDiaryEmotion(_ diary: Diary) async throws -> EmotionStatistics
}

public final class DefaultDiaryUseCase: DiaryUseCase {
    private let diaryRepository: DiaryRepository
    private let emotionAnalysisService: EmotionAnalysisService
    private let contentSummaryService: ContentSummaryService
    
    public init(
        diaryRepository: DiaryRepository,
        emotionAnalysisService: EmotionAnalysisService,
        contentSummaryService: ContentSummaryService
    ) {
        self.diaryRepository = diaryRepository
        self.emotionAnalysisService = emotionAnalysisService
        self.contentSummaryService = contentSummaryService
    }
    
    public func createDiary(_ diary: Diary) async throws {
        let emotion = try await emotionAnalysisService.analyzeEmotion(from: diary.content)
        let summary = try await contentSummaryService.summarize(diary.content)
        
        var updatedDiary = diary
        updatedDiary.emotion = emotion
        updatedDiary.summary = summary
        
        try await diaryRepository.saveDiary(updatedDiary)
    }
    
    public func updateDiary(_ diary: Diary) async throws {
        let emotion = try await emotionAnalysisService.analyzeEmotion(from: diary.content)
        let summary = try await contentSummaryService.summarize(diary.content)
        
        var updatedDiary = diary
        updatedDiary.emotion = emotion
        updatedDiary.summary = summary
        
        try await diaryRepository.updateDiary(updatedDiary)
    }
    
    public func deleteDiary(_ diary: Diary) async throws {
        try await diaryRepository.deleteDiary(diary)
    }
    
    public func getDiaries() async throws -> [Diary] {
        try await diaryRepository.getDiaries()
    }
    
    public func analyzeDiaryEmotion(_ diary: Diary) async throws -> EmotionStatistics {
        let emotionResult = try await emotionAnalysisService.analyzeEmotion(from: diary.content)
        let emotion = EmotionStatistics.Emotion(name: emotionResult, count: 1)
        return EmotionStatistics(
            emotions: [emotion],
            startDate: diary.date,
            endDate: diary.date
        )
    }
}
