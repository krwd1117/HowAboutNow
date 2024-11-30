import SwiftUI
import Feature
import Core

struct ContentView: View {
    private let repository: DiaryRepository
    
    init() {
        do {
            repository = try DiaryDataRepository()
        } catch {
            fatalError("Failed to initialize repository: \(error)")
        }
    }
    
    var body: some View {
        NavigationStack {
            DiaryListView(viewModel: DiaryListViewModel(repository: repository))
                .navigationTitle("How About Now")
        }
    }
}

#Preview {
    ContentView()
}
