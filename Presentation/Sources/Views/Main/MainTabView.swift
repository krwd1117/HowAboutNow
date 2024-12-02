import SwiftUI
import Domain

public struct MainTabView: View {
    @State private var selectedTab = 0
    private let repository: DiaryRepository
    private let diaryAnalysisService: DiaryAnalysisService
    
    public init(repository: DiaryRepository, 
               diaryAnalysisService: DiaryAnalysisService) {
        self.repository = repository
        self.diaryAnalysisService = diaryAnalysisService
    }
    
    public var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                DiaryView(
                    viewModel: DiaryListViewModel(
                        repository: repository,
                        diaryAnalysisService: diaryAnalysisService
                    )
                )
                .tabItem {
                    Label(LocalizedStringKey("diary"), systemImage: "book.fill")
                }
                .tag(0)
                
                SettingsView()
                    .tabItem {
                        Label(LocalizedStringKey("settings"), systemImage: "gearshape.fill")
                    }
                    .tag(1)
            }
            .ignoresSafeArea(.keyboard)
            .tint(.pink)
        }
    }
}
