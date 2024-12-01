import SwiftUI
import Infrastructure
import Domain

public struct MainTabView: View {
    @State private var selectedTab = 0
    private let repository: DiaryRepository
    private let emotionAnalysisService: EmotionAnalysisService
    
    public init(repository: DiaryRepository, emotionAnalysisService: EmotionAnalysisService) {
        self.repository = repository
        self.emotionAnalysisService = emotionAnalysisService
    }
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                DiaryListView(viewModel: DiaryListViewModel(repository: repository, emotionAnalysisService: emotionAnalysisService))
                    .navigationBarTitleDisplayMode(.large)
            }
            .tag(0)
            .tabItem {
                Label("일기", systemImage: selectedTab == 0 ? "book.fill" : "book")
            }
            
            NavigationStack {
                EmotionStatisticsView(viewModel: EmotionStatisticsViewModel(repository: repository))
                    .navigationBarTitleDisplayMode(.large)
            }
            .tag(1)
            .tabItem {
                Label("통계", systemImage: selectedTab == 1 ? "chart.pie.fill" : "chart.pie")
            }
        }
        .ignoresSafeArea(.keyboard)
        .tint(.pink)
    }
}
