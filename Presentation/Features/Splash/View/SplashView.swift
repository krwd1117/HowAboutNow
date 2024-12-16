import SwiftUI
import Domain

/// 스플래시 화면
public struct SplashView: View {
    @EnvironmentObject private var appcoordinator: AppCoordinator
    @ObservedObject private var viewModel: SplashViewModel
    @State private var size = 0.7
    @State private var opacity = 0.3
    @State private var showError = false
    
    public init(viewModel: SplashViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ZStack {
            /// 배경 색상
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                /// 앱 로고
                Image(systemName: "book.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.pink)
                    .scaleEffect(size)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeIn(duration: 1.2)) {
                            self.size = 0.9
                            self.opacity = 1.0
                        }
                    }
                
                /// 앱 제목
                Text("app_name")
                    .font(.title)
                    .fontWeight(.bold)
                    .opacity(opacity)
            }
        }
        .task {
            await viewModel.initializeServices()
            appcoordinator.navitateToMainTab()
        }
    }
}
