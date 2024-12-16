import Foundation
import Domain

public final class SplashViewModel: ObservableObject {
    
    @Published public private(set) var isInitialized = false
    @Published public private(set) var error: Error?
    
    public private(set) var initialDiaries: [Diary]?

    let diContainer: DIContainerProtocol
    
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

            await diContainer.updateOpenAIConfigurationUseCase.execute(configuration: initialOpenAIConfigurateion)

            self.isInitialized = true
            self.error = nil
        } catch {
            self.isInitialized = false
            self.error = error
        }
    }
}
