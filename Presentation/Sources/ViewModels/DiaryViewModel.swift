import Foundation
import Domain
import Combine

@MainActor
public final class DiaryViewModel: ObservableObject {
    @Published public private(set) var diaries: [Diary] = []
    @Published public private(set) var isLoading = false
    @Published public var selectedDate = Date()
    @Published public var selectedDiary: Diary?
    @Published public var diaryToDelete: Diary?
    
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
        await MainActor.run {
            isLoading = true
        }
        defer {
            Task { @MainActor in
                isLoading = false
            }
        }
        
        do {
            let loadedDiaries = try await diaryRepository.getDiaries()
            await MainActor.run {
                diaries = loadedDiaries
            }
        } catch {
            print("Error loading diaries: \(error)")
        }
    }
    
    public var filteredDiaries: [Diary] {
        diaries.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }
    
    public func selectDiary(_ diary: Diary?) {
        selectedDiary = diary
    }
    
    @MainActor
    public func markForDeletion(_ diary: Diary?) {
        diaryToDelete = diary
    }
    
    public func saveDiary(diary: Diary) async throws {
        do {
            let analysis = try await diaryAnalysisService.analyzeDiary(content: diary.content)
            let analyzedDiary = Diary(
                id: diary.id,
                title: diary.title,
                content: diary.content,
                emotion: analysis.emotion,
                summary: analysis.summary,
                date: diary.date
            )
            try await diaryRepository.saveDiary(analyzedDiary)
            await loadDiaries()
        } catch {
            throw error
        }
    }
    
    public func updateDiary(_ diary: Diary, title: String, content: String, emotion: String) async {
        do {
            let updatedDiary = Diary(
                id: diary.id,
                title: title,
                content: content,
                emotion: emotion,
                summary: diary.summary,
                date: diary.date
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
            await MainActor.run {
                diaries.removeAll { $0.id == diary.id }
            }
        } catch {
            print("Error deleting diary: \(error)")
        }
    }
    
    private func sortDiaries() {
        diaries.sort { $0.date > $1.date }
    }
}
