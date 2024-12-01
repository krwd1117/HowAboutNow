import SwiftUI
import Infrastructure
import Domain

public struct MainTabView: View {
    @State private var selectedTab = 0
    private let repository: DiaryRepository
    private let emotionAnalysisService: EmotionAnalysisService
    private let contentSummaryService: ContentSummaryService
    
    public init(repository: DiaryRepository, 
               emotionAnalysisService: EmotionAnalysisService,
               contentSummaryService: ContentSummaryService) {
        self.repository = repository
        self.emotionAnalysisService = emotionAnalysisService
        self.contentSummaryService = contentSummaryService
    }
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                DiaryListView(viewModel: DiaryListViewModel(
                    repository: repository, 
                    emotionAnalysisService: emotionAnalysisService,
                    contentSummaryService: contentSummaryService
                ))
                    .navigationBarTitleDisplayMode(.large)
            }
            .tag(0)
            .tabItem {
                Label("일기", systemImage: selectedTab == 0 ? "book.fill" : "book")
            }
            
            NavigationStack {
                SettingsView()
                    .navigationBarTitleDisplayMode(.large)
            }
            .tag(1)
            .tabItem {
                Label("설정", systemImage: selectedTab == 1 ? "gearshape.fill" : "gearshape")
            }
        }
        .ignoresSafeArea(.keyboard)
        .tint(.pink)
    }
}
