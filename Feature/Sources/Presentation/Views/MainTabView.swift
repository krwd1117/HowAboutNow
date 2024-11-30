import SwiftUI
import Core

public struct MainTabView: View {
    @State private var selectedTab = 0
    private let repository: DiaryRepository
    
    public init(repository: DiaryRepository) {
        self.repository = repository
    }
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                DiaryListView(viewModel: DiaryListViewModel(repository: repository))
            }
            .tag(0)
            .tabItem {
                Label("일기", systemImage: selectedTab == 0 ? "book.fill" : "book")
            }
            
            NavigationStack {
                EmotionStatisticsView(viewModel: EmotionStatisticsViewModel(repository: repository))
            }
            .tag(1)
            .tabItem {
                Label("통계", systemImage: selectedTab == 1 ? "chart.pie.fill" : "chart.pie")
            }
        }
        .tint(.pink)
    }
}

#Preview {
    MainTabView(repository: MockDiaryRepository())
}
