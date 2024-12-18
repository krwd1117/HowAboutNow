import Foundation
import Domain
import Combine

public final class DiaryListViewModel: ObservableObject {
    @Published private(set) var diaries: [Diary] = []
    @Published public private(set) var isLoading = false
    @Published public var selectedDate = Date()
    @Published public var showingListView = false

    private let diContainer: DIContainerProtocol

    public var filteredDiaries: [Diary] {
        showingListView ? diaries : diaries.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }

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
    public func loadDiaries() {
        isLoading = true

        Task {
            do {
                let loadedDiaries = try await diContainer.fetchDiariesUseCase.execute()
                diaries = loadedDiaries
                isLoading = false
            } catch {
                print("Error loading diaries: \(error)")
                isLoading = false
            }
        }
    }

    // DiaryEditorViewModel에서 사용
    public func deleteDiary(_ diary: Diary) async {
        do {
            try await diContainer.deleteDiaryUseCase.execute(diary: diary)
            await loadDiaries()
        } catch {
            print("Error deleting diary: \(error)")
        }
    }
}
