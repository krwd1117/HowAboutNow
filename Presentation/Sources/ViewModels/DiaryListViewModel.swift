import Foundation
import Infrastructure
import Domain

@MainActor
public final class DiaryListViewModel: ObservableObject {
    @Published private(set) var diaries: [Diary] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published public var isCalendarView: Bool
    
    internal let repository: DiaryRepository
    private let emotionAnalysisService: EmotionAnalysisService
    private let contentSummaryService: ContentSummaryService
    private let defaults = UserDefaults.standard
    private let viewModeKey = "DiaryViewMode"
    
    public init(repository: DiaryRepository, 
               emotionAnalysisService: EmotionAnalysisService,
               contentSummaryService: ContentSummaryService) {
        self.repository = repository
        self.emotionAnalysisService = emotionAnalysisService
        self.contentSummaryService = contentSummaryService
        self.isCalendarView = UserDefaults.standard.bool(forKey: "DiaryViewMode")
    }
    
    public func toggleViewMode() {
        isCalendarView.toggle()
        defaults.set(isCalendarView, forKey: viewModeKey)
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
