import Foundation
import SwiftUI
@preconcurrency import SwiftUI
import Core

@MainActor
public final class DiaryListViewModel: ObservableObject {
    @Published private(set) var diaries: [Diary] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    internal let repository: DiaryRepository
    private let emotionAnalysisService: EmotionAnalysisService
    
    public init(repository: DiaryRepository, emotionAnalysisService: EmotionAnalysisService) {
        self.repository = repository
        self.emotionAnalysisService = emotionAnalysisService
    }
    
    public func loadDiaries() async {
        isLoading = true
        error = nil
        
        do {
            diaries = try await repository.getDiaries()
                .sorted { $0.date > $1.date }
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    public func addDiary(title: String, content: String, date: Date) async {
        guard !title.isEmpty && !content.isEmpty else { return }
        
        isLoading = true
        error = nil
        
        do {
            let emotion = try await emotionAnalysisService.analyzeEmotion(from: content)
            let diary = Diary(title: title, content: content, emotion: emotion, date: date)
            try await repository.saveDiary(diary)
            await loadDiaries()
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    public func updateDiary(_ diary: Diary, title: String, content: String, date: Date) async {
        guard !title.isEmpty && !content.isEmpty else { return }
        
        isLoading = true
        error = nil
        
        do {
            let emotion = try await emotionAnalysisService.analyzeEmotion(from: content)
            let updatedDiary = Diary(id: diary.id, title: title, content: content, emotion: emotion, date: date)
            try await repository.updateDiary(updatedDiary)
            await loadDiaries()
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    public func deleteDiary(_ diary: Diary) async {
        isLoading = true
        error = nil
        
        do {
            try await repository.deleteDiary(diary)
            await loadDiaries()
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
}
