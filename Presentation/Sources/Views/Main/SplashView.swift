import SwiftUI
import Domain
import Infrastructure

public struct SplashView: View {
    @StateObject private var viewModel = SplashViewModel()
    @State private var size = 0.7
    @State private var opacity = 0.3
    @State private var showError = false
    
    public init() {}
    
    public var body: some View {
        Group {
            if viewModel.isInitialized {
                if let repository = viewModel.repository,
                   let diaryAnalysisService = viewModel.diaryAnalysisService {
                    MainTabView(
                        repository: repository,
                        diaryAnalysisService: diaryAnalysisService
                    )
                }
            } else {
                ZStack {
                    Color(uiColor: .systemBackground)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 24) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(.tint)
                            .symbolEffect(.bounce, options: .repeating)
                        
                        VStack(spacing: 8) {
                            Text("app_name")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("record_your_day")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        if showError {
                            VStack {
                                Text("error_initialization")
                                    .font(.callout)
                                    .foregroundStyle(.red)
                                
                                Button("retry") {
                                    Task {
                                        await viewModel.initializeServices()
                                    }
                                }
                                .buttonStyle(.bordered)
                            }
                            .padding(.top, 8)
                        }
                    }
                    .opacity(opacity)
                    .scaleEffect(size)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.2)) {
                            self.size = 1.0
                            self.opacity = 1.0
                        }
                        
                        Task {
                            Logger.d("Initializing services...")
                            await viewModel.initializeServices()
                        }
                    }
                }
            }
        }
    }
}