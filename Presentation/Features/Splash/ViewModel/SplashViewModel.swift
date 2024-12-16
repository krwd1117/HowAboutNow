import Foundation
import Domain

public final class SplashViewModel: ObservableObject {
    
    private let diContainer: DIContainerProtocol
    
    public private(set) var initialDiaries: [Diary]?
    
    public init(diContainer: DIContainerProtocol) {
        self.diContainer = diContainer
    }
    
    @MainActor
    public func initializeServices() async {
        do {
            self.initialDiaries = try await diContainer.fetchDiaryUseCase.execute()

            let initialOpenAIConfigurateion = try await diContainer.fetchOpenAIConfigurationUseCase.execute(
               collection: "AIConfigurations",
               document: "Settings"
           )
            // OpenAI Prompt 업데이트
            await diContainer.updateOpenAIConfigurationUseCase.execute(
                configuration: initialOpenAIConfigurateion
            )

        } catch {
            
        }
    }
}
