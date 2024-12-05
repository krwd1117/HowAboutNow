import Foundation
import Domain
import Combine

@MainActor
public final class DiaryViewModel: ObservableObject {
    @Published public private(set) var diaries: [Diary] = []
    @Published public private(set) var isLoading = false
    
    private let diaryRepository: any DiaryRepository
    private let diaryAnalysisService: any DiaryAnalysisService
    
    public init(
        diaryRepository: any DiaryRepository,
        diaryAnalysisService: any DiaryAnalysisService
    ) {
        self.diaryRepository = diaryRepository
        self.diaryAnalysisService = diaryAnalysisService
    }
    
    public func loadDiaries() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            diaries = try await diaryRepository.getDiaries()
        } catch {
            print("Error loading diaries: \(error)")
        }
    }
    
    public func saveDiary(title: String, content: String, date: Date) async {
        do {
            let analysis = try await diaryAnalysisService.analyzeDiary(content: content)
            let diary = Diary(
                title: title,
                content: content,
                emotion: analysis.emotion,
                summary: analysis.summary,
                date: date
            )
            try await diaryRepository.saveDiary(diary)
            await loadDiaries()
        } catch {
            print("Error saving diary: \(error)")
        }
    }
    
    public func updateDiary(
        _ diary: Diary,
        title: String,
        content: String,
        date: Date,
        emotion: String
    ) async {
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
            try await diaryRepository.updateDiary(updatedDiary)
            await loadDiaries()
        } catch {
            print("Error updating diary: \(error)")
        }
    }
    
    public func deleteDiary(_ diary: Diary) async {
        do {
            try await diaryRepository.deleteDiary(diary)
            diaries.removeAll { $0.id == diary.id }
        } catch {
            print("Error deleting diary: \(error)")
        }
    }
    
    private func sortDiaries() {
        diaries.sort { $0.date > $1.date }
    }
}
