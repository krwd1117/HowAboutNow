import SwiftUI
import Feature
import Core

class MockDiaryRepository: DiaryRepository {
    func getDiaries() async throws -> [Diary] {
        return []
    }
    
    func saveDiary(_ diary: Diary) async throws {}
    func updateDiary(_ diary: Diary) async throws {}
    func deleteDiary(_ diary: Diary) async throws {}
}

struct ContentView: View {
    var body: some View {
        NavigationStack {
            DiaryListView(viewModel: DiaryListViewModel(repository: MockDiaryRepository()))
                .navigationTitle("How About Now")
        }
    }
}

#Preview {
    ContentView()
}
