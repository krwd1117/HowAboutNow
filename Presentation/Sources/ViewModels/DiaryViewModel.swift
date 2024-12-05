import Foundation
import Domain

public final class DiaryViewModel: ObservableObject {
    @Published private(set) var diaries: [Diary] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published public var isCalendarView: Bool
    
    private let repository: DiaryRepository
    private let diaryAnalysisService: DiaryAnalysisService
    private let defaults = UserDefaults.standard
    private let viewModeKey = "DiaryViewMode"
    
    public nonisolated init(repository: DiaryRepository,
                          diaryAnalysisService: DiaryAnalysisService) {
        self.repository = repository
        self.diaryAnalysisService = diaryAnalysisService
        self.isCalendarView = UserDefaults.standard.bool(forKey: "DiaryViewMode")
    }
    
    public nonisolated func toggleViewMode() {
        isCalendarView.toggle()
        defaults.set(isCalendarView, forKey: viewModeKey)
    }
    
    @MainActor
    public func loadDiaries() async {
        isLoading = true
        error = nil
        
        do {
            let fetchedDiaries = try await repository.getDiaries()
            diaries = fetchedDiaries.sorted { $0.date > $1.date }
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    @MainActor
    public func saveDiary(title: String, content: String, date: Date) async {
        guard !title.isEmpty && !content.isEmpty else { return }
        
        isLoading = true
        error = nil
        
        do {
            let analysis = try await diaryAnalysisService.analyzeDiary(content: content)
            let diary = Diary(
                title: title,
                content: content,
                emotion: analysis.emotion,
                summary: analysis.summary,
                date: date
            )
            
            try await repository.saveDiary(diary)
            await loadDiaries()
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    @MainActor
    public func updateDiary(_ diary: Diary, title: String, content: String, date: Date, emotion: String) async {
        guard !title.isEmpty && !content.isEmpty else { return }
        
        isLoading = true
        error = nil
        
        do {
            let analysis = try await diaryAnalysisService.analyzeDiary(content: content)
            let updatedDiary = Diary(
                id: diary.id,
                title: title,
                content: content,
                emotion: emotion.isEmpty ? analysis.emotion : emotion,
                summary: analysis.summary,
                date: date
            )
            
            try await repository.updateDiary(updatedDiary)
            await loadDiaries()
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    @MainActor
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
