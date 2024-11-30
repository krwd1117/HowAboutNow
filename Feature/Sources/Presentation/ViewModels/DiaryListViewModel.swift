import Foundation
import Core

@Observable
public class DiaryListViewModel {
    public let repository: DiaryRepository
    private let emotionAnalysisService: EmotionAnalysisService
    public private(set) var diaries: [Diary] = []
    public private(set) var error: Error?
    
    public init(repository: DiaryRepository, emotionAnalysisService: EmotionAnalysisService) {
        self.repository = repository
        self.emotionAnalysisService = emotionAnalysisService
        Task { @MainActor in
            await fetchDiaries()
        }
    }
    
    @MainActor
    public func fetchDiaries() async {
        do {
            diaries = try await repository.getDiaries()
            Logger.d("Fetched \(diaries.count) diaries")
        } catch {
            Logger.e("Failed to fetch diaries: \(error)")
            self.error = error
        }
    }
    
    @MainActor
    public func addDiary(content: String) async {
        do {
            let emotion = try await emotionAnalysisService.analyzeEmotion(from: content)
            let diary = Diary(content: content, emotion: emotion)
            try await repository.saveDiary(diary)
            await fetchDiaries()
            Logger.d("Added new diary with emotion: \(emotion)")
        } catch {
            Logger.e("Failed to add diary: \(error)")
            self.error = error
        }
    }
    
    @MainActor
    public func updateDiary(_ diary: Diary, content: String) async {
        do {
            let emotion = try await emotionAnalysisService.analyzeEmotion(from: content)
            var updatedDiary = diary
            updatedDiary.content = content
            updatedDiary.emotion = emotion
            updatedDiary.date = .now
            try await repository.updateDiary(updatedDiary)
            await fetchDiaries()
            Logger.d("Updated diary with emotion: \(emotion)")
        } catch {
            Logger.e("Failed to update diary: \(error)")
            self.error = error
        }
    }
    
    @MainActor
    public func deleteDiaries(at indexSet: IndexSet) async {
        for index in indexSet {
            let diary = diaries[index]
            do {
                try await repository.deleteDiary(diary)
                await fetchDiaries()
                Logger.d("Deleted diary")
            } catch {
                Logger.e("Failed to delete diary: \(error)")
                self.error = error
            }
        }
    }
    
    @MainActor
    public func deleteDiary(_ diary: Diary) async {
        do {
            try await repository.deleteDiary(diary)
            await fetchDiaries()
            Logger.d("Deleted diary")
        } catch {
            Logger.e("Failed to delete diary: \(error)")
            self.error = error
        }
    }
}
