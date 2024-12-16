import SwiftUI
import Domain

public struct BottomTabView: View {
    @EnvironmentObject private var bottomTabCoordinator: BottomTabCoordinator
    private let diContainer: DIContainerProtocol

    public init(diContainer: DIContainerProtocol) {
        self.diContainer = diContainer
    }

    public var body: some View {
        VStack {
            // 현재 선택된 탭에 따라 화면 표시
            ZStack {
                switch bottomTabCoordinator.selectedTab {
                case .diary:
                    DiaryView(diContainer: diContainer)
                        .environmentObject(DiaryCoordinator(diContainer: diContainer))
                case .setting:
                    SettingsView()
                }
            }

            // 커스텀 탭 바
            HStack {
                Spacer()
                tabBarItem(
                    title: "diary",
                    image: "book.fill",
                    tab: .diary
                )
                Spacer()
                tabBarItem(
                    title: "settings",
                    image: "gearshape.fill",
                    tab: .setting
                )
                Spacer()
            }
            .frame(height: 50)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    // 커스텀 탭 아이템
    private func tabBarItem(title: String, image: String, tab: BottomTabCoordinator.Tab) -> some View {
        Button(action: {
            handleTabChange(to: tab)
        }) {
            VStack {
                Image(systemName: image)
                Text(LocalizedStringKey(title))
                    .font(.footnote)
            }
            .foregroundColor(bottomTabCoordinator.selectedTab == tab ? .pink : .gray)
        }
    }

    // 탭 전환 로직
    private func handleTabChange(to tab: BottomTabCoordinator.Tab) {
        if tab == bottomTabCoordinator.selectedTab {
            print("\(tab) is already selected")
        } else {
            switch tab {
            case .diary:
                bottomTabCoordinator.switchToDiary()
            case .setting:
                bottomTabCoordinator.switchToSetting()
            }
        }
    }
}
