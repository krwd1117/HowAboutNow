import Foundation
import Domain
import Combine
import DI

@MainActor
public final class DiaryViewModel: ObservableObject {
    @Published public private(set) var diaries: [Diary] = []
    @Published public private(set) var isLoading = false
    @Published public var selectedDate = Date()
    
    private let addDiaryUseCase: AddDiaryUseCase
    private let fetchUseCase: FetchDiaryUseCase
    private let updateUseCase: UpdateDiaryUseCase
    private let deleteUseCase: DeleteDiaryUseCase
    private let analysisDiaryUseCase: AnalysisDiaryUseCase
    
    public init(
        addDiaryUseCase: AddDiaryUseCase? = nil,
        fetchUseCase: FetchDiaryUseCase? = nil,
        updateUseCase: UpdateDiaryUseCase? = nil,
        deleteUseCase: DeleteDiaryUseCase? = nil,
        analysisDiaryUseCase: AnalysisDiaryUseCase? = nil,
        initialDiaries: [Diary]? = nil
    ) {
        
        self.addDiaryUseCase = addDiaryUseCase ?? DIContainer.shared.resolve(AddDiaryUseCase.self)
        self.fetchUseCase = fetchUseCase ?? DIContainer.shared.resolve(FetchDiaryUseCase.self)
        self.updateUseCase = updateUseCase ?? DIContainer.shared.resolve(UpdateDiaryUseCase.self)
        self.deleteUseCase = deleteUseCase ?? DIContainer.shared.resolve(DeleteDiaryUseCase.self)
        self.analysisDiaryUseCase = analysisDiaryUseCase ?? DIContainer.shared.resolve(AnalysisDiaryUseCase.self)
        
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
            let loadedDiaries = try await fetchUseCase.execute()
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
        try await addDiaryUseCase.execute(diary: diary)
        await loadDiaries()
        
        // 백그라운드에서 감정 분석 수행
        Task.detached { [weak self] in
            do {
                let analysis = try await self?.analysisDiaryUseCase.excute(diary: diary)
                
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
                
                try await self?.updateUseCase.execute(diary: analyzedDiary)
                
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
            try await updateUseCase.execute(diary: updatedDiary)
            await loadDiaries()
        } catch {
            print("Error updating diary: \(error)")
        }
    }
    
    public func deleteDiary(_ diary: Diary) async {
        do {
            try await deleteUseCase.execute(diary: diary)
            await loadDiaries()
        } catch {
            print("Error deleting diary: \(error)")
        }
    }
}
