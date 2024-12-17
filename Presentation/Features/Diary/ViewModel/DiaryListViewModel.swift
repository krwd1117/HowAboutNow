import Foundation
import Domain
import Combine

@MainActor
public final class DiaryListViewModel: ObservableObject {
    @Published public private(set) var diaries: [Diary] = []
    @Published public private(set) var isLoading = false
    @Published public var selectedDate = Date()
    
    private let diContainer: DIContainerProtocol
    
    public init(
        diContainer: DIContainerProtocol,
        initialDiaries: [Diary]? = nil
    ) {
        self.diContainer = diContainer
        if let initialDiaries {
            self.diaries = initialDiaries
        }
    }

    // 다이어리 초기 값 불러옴
    @MainActor
    public func loadDiaries() async {
        isLoading = true

        defer {
            isLoading = false
        }
        do {
            let loadedDiaries = try await diContainer.fetchDiaryUseCase.execute()
            diaries = loadedDiaries
        } catch {
            print("Error loading diaries: \(error)")
        }
    }
    
    public var filteredDiaries: [Diary] {
        diaries.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }
    
    public func saveDiary(diary: Diary) async throws {
        // 먼저 일기를 저장
        try await diContainer.addDiaryUseCase.execute(diary: diary)
        await loadDiaries()
        
        // 백그라운드에서 감정 분석 수행
        Task.detached { [weak self] in
            do {
                let analysis = try await self?.diContainer.analysisDiaryUseCase.excute(diary: diary)
                
                guard let analysis = analysis else {
                    return
                }
                
                let analyzedDiary = Diary(
                    id: diary.id,
                    title: diary.title.isEmpty ? analysis.title : diary.title,
                    content: diary.content,
                    emotion: analysis.emotion,
                    summary: analysis.summary,
                    date: diary.date
                )
                
                try? await self?.diContainer.updateDiaryUseCase.execute(diary: analyzedDiary)
                Task {
                    await self?.loadDiaries()
                }
            } catch {
                print("Error analyzing diary: \(error)")
            }
        }
    }
    
    public func updateDiary(_ diary: Diary, title: String, content: String, emotion: String, date: Date) async {
        do {
            let updatedDiary = Diary(
                id: diary.id,
                title: title,
                content: content,
                emotion: emotion,
                summary: diary.summary,
                date: date
            )
            try await diContainer.updateDiaryUseCase.execute(diary: updatedDiary)
            await loadDiaries()
        } catch {
            print("Error updating diary: \(error)")
        }
    }
    
    public func deleteDiary(_ diary: Diary) async {
        do {
            try await diContainer.deleteDiaryUseCase.execute(diary: diary)
            await loadDiaries()
        } catch {
            print("Error deleting diary: \(error)")
        }
    }
}