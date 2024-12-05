import SwiftUI
import Domain

public struct SplashView: View {
    @StateObject private var viewModel: SplashViewModel
    @State private var size = 0.7
    @State private var opacity = 0.3
    @State private var showError = false
    
    public init(
        repositoryProvider: @escaping () -> DiaryRepository,
        serviceProvider: @escaping () throws -> DiaryAnalysisService
    ) {
        _viewModel = StateObject(wrappedValue: SplashViewModel(
            repositoryProvider: repositoryProvider,
            serviceProvider: serviceProvider
        ))
    }
    
    public var body: some View {
        Group {
            if viewModel.isInitialized {
                if let repository = viewModel.repository,
                   let diaryAnalysisService = viewModel.diaryAnalysisService {
                    MainTabView(
                        repository: repository,
                        diaryAnalysisService: diaryAnalysisService
                    )
                } else {
                    ErrorView(message: "Failed to initialize services")
                }
            } else {
                ZStack {
                    Color(uiColor: .systemBackground)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 24) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(.tint)
                            .scaleEffect(size)
                            .opacity(opacity)
                            .onAppear {
                                withAnimation(.easeIn(duration: 1.2)) {
                                    self.size = 0.9
                                    self.opacity = 1.0
                                }
                            }
                        
                        Text("How About Now")
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
