import SwiftUI
import Domain

/// 스플래시 화면
public struct SplashView: View {    
    /// 뷰 모델
    @ObservedObject private var viewModel: SplashViewModel
    /// 애니메이션 크기
    @State private var size = 0.7
    /// 애니메이션 불투명도
    @State private var opacity = 0.3
    /// 에러 표시 여부
    @State private var showError = false
    
    /// 초기화
    /// - Parameters:
    ///   - repositoryProvider: 저장소 제공자
    ///   - serviceProvider: 서비스 제공자
    public init(viewModel: SplashViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        Group {
            if viewModel.isInitialized {
                MainTabView()
            } else {
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
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") {
                showError = false
            }
        } message: {
            if let error = viewModel.error {
                Text(error.localizedDescription)
            }
        }
    }
}
