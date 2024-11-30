import Foundation
import SwiftUI
import Core

@Observable
public class DiaryListViewModel {
    private let repository: DiaryRepository
    private let emotionAnalysisService: EmotionAnalysisService
    public var diaries: [Diary] = []
    public var error: Error?
    
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
            print("Fetched \(diaries.count) diaries")
        } catch {
            self.error = error
            print("Failed to fetch diaries: \(error)")
        }
    }
    
    @MainActor
    public func addDiary(content: String) async {
        do {
            // 1. 감정 분석
            let emotion = try await emotionAnalysisService.analyzeEmotion(from: content)
            print("Analyzed emotion: \(emotion)")
            
            // 2. 일기 저장
            let diary = Diary(content: content, emotion: emotion)
            try await repository.saveDiary(diary)
            print("Successfully added new diary with emotion: \(emotion)")
            
            // 3. 목록 갱신
            await fetchDiaries()
        } catch {
            self.error = error
            print("Failed to add diary: \(error)")
        }
    }
    
    @MainActor
    public func updateDiary(_ diary: Diary, content: String) async {
        do {
            // 1. 감정 분석
            let emotion = try await emotionAnalysisService.analyzeEmotion(from: content)
            print("Analyzed emotion: \(emotion)")
            
            // 2. 일기 업데이트
            diary.content = content
            diary.emotion = emotion
            diary.date = .now
            
            try await repository.updateDiary(diary)
            print("Successfully updated diary: \(diary.id)")
            
            // 3. 목록 갱신
            await fetchDiaries()
        } catch {
            self.error = error
            print("Failed to update diary: \(error)")
        }
    }
    
    @MainActor
    public func deleteDiaries(at indexSet: IndexSet) async {
        for index in indexSet {
            let diary = diaries[index]
            do {
                try await repository.deleteDiary(diary)
                print("Successfully deleted diary: \(diary.id)")
            } catch {
                self.error = error
                print("Failed to delete diary: \(diary.id)")
            }
        }
        await fetchDiaries()
    }
}
