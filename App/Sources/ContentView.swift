import SwiftUI
import Feature
import Core

struct ContentView: View {
    private let repository: DiaryRepository
    private let emotionAnalysisService: EmotionAnalysisService
    
    init() {
        do {
            let apiKey = try ConfigurationManager.shared.string(for: ConfigurationManager.Keys.openAIAPIKey)
            repository = try DiaryDataRepository()
            emotionAnalysisService = OpenAIEmotionAnalysisService(apiKey: apiKey)
        } catch {
            fatalError("Failed to initialize: \(error)")
        }
    }
    
    var body: some View {
        NavigationStack {
            DiaryListView(viewModel: DiaryListViewModel(
                repository: repository,
                emotionAnalysisService: emotionAnalysisService
            ))
            .navigationTitle("How About Now")
        }
    }
}

#Preview {
    ContentView()
}
