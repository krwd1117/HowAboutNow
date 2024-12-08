import Foundation
import Domain
import Combine

@MainActor
public final class DiaryViewModel: ObservableObject {
    @Published public private(set) var diaries: [Diary] = []
    @Published public private(set) var isLoading = false
    @Published public var selectedDate = Date()
    
    private let diaryRepository: any DiaryRepository
    private let diaryAnalysisService: any DiaryAnalysisService
    
    public init(
        diaryRepository: any DiaryRepository,
        diaryAnalysisService: any DiaryAnalysisService,
        initialDiaries: [Diary]? = nil
    ) {
        self.diaryRepository = diaryRepository
        self.diaryAnalysisService = diaryAnalysisService
        if let initialDiaries {
            self.diaries = initialDiaries
        }
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
    
    public func saveDiary(diary: Diary) async throws {
        // 먼저 일기를 저장
        try await diaryRepository.saveDiary(diary)
        await loadDiaries()
        
        // 백그라운드에서 감정 분석 수행
        Task.detached { [weak self] in
            do {
                let analysis = try await self?.diaryAnalysisService.analyzeDiary(content: diary.content)
                guard let analysis = analysis else { return }
                
                let analyzedDiary = Diary(
                    id: diary.id,
                    title: diary.title,
                    content: diary.content,
                    emotion: analysis.emotion,
                    summary: analysis.summary,
                    date: diary.date
                )
                
                // UI 스레드에서 일기 업데이트
                try? await self?.diaryRepository.updateDiary(analyzedDiary)
                Task {
                    await self?.loadDiaries()
                }
            } catch {
                print("Error analyzing diary: \(error)")
            }
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
            await loadDiaries()
        } catch {
            print("Error deleting diary: \(error)")
        }
    }
}
