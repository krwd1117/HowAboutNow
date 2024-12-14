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
    
    private let diContainer: DIContainerProtocol
    
    /// 초기화
    public init(diContainer: DIContainerProtocol) {
        self.diContainer = diContainer
    }
    
    public var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                // 다이어리 목록 탭
                let viewModel = DiaryViewModel(diContainer: diContainer)
                DiaryView(viewModel: viewModel)
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
