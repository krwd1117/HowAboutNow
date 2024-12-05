import SwiftUI
import Domain

/// 메인 탭 뷰
public struct MainTabView: View {
    /// 선택된 탭
    @State private var selectedTab = 0
    
    /// 탭 열거형
    private enum Tab {
        case list
        case settings
    }
    
    private let repository: DiaryRepository
    private let diaryAnalysisService: DiaryAnalysisService
    
    /// 초기화
    public init(repository: DiaryRepository, 
               diaryAnalysisService: DiaryAnalysisService) {
        self.repository = repository
        self.diaryAnalysisService = diaryAnalysisService
    }
    
    public var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                // 다이어리 목록 탭
                DiaryView(
                    viewModel: DiaryViewModel(
                        repository: repository,
                        diaryAnalysisService: diaryAnalysisService
                    )
                )
                .tag(0)
                .tabItem {
                    Label(LocalizedStringKey("diary"), systemImage: "book.fill")
                }
                
                // 설정 탭
                SettingsView()
                    .tag(1)
                    .tabItem {
                        Label(LocalizedStringKey("settings"), systemImage: "gearshape.fill")
                    }
            }
            .ignoresSafeArea(.keyboard)
            .tint(.pink)
        }
    }
}
