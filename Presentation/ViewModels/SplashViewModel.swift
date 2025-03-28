import Foundation

import DI
import Domain

public final class SplashViewModel: ObservableObject {
    
    @Published public private(set) var isInitialized = false
    @Published public private(set) var error: Error?
    
    public private(set) var initialDiaries: [Diary]?
    
    private let fetchDiaryUseCase: FetchDiaryUseCase
    private let fetchOpenAIConfigurationUseCase: FetchOpenAIConfigurationUseCase
    private let updateOpenAIConfigurationUseCase: UpdateOpenAIConfigurationUseCase
    
    public init(
        fetchDiaryUseCase: FetchDiaryUseCase? = nil,
        fetchOpenAIConfigurationUseCase: FetchOpenAIConfigurationUseCase? = nil,
        updateOpenAIConfigurationUseCase: UpdateOpenAIConfigurationUseCase? = nil
    ) {
        self.fetchDiaryUseCase = fetchDiaryUseCase ?? DIContainer.shared.resolve(FetchDiaryUseCase.self)
        self.fetchOpenAIConfigurationUseCase = fetchOpenAIConfigurationUseCase ?? DIContainer.shared.resolve(FetchOpenAIConfigurationUseCase.self)
        self.updateOpenAIConfigurationUseCase = updateOpenAIConfigurationUseCase ?? DIContainer.shared.resolve(UpdateOpenAIConfigurationUseCase.self)
    }
    
    @MainActor
    public func initializeServices() async {
        do {
            self.initialDiaries = try await fetchDiaryUseCase.execute()

            let initialOpenAIConfigurateion = try await fetchOpenAIConfigurationUseCase.execute(
                collection: "AIConfigurations", document: "Settings"
            )

            await updateOpenAIConfigurationUseCase.execute(configuration: initialOpenAIConfigurateion)

            self.isInitialized = true
            self.error = nil
        } catch {
            self.isInitialized = false
            self.error = error
        }
    }
}
