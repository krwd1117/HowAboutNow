import Foundation

public protocol FetchDiariesUseCaseProtocol {
    func execute() async throws -> [Diary]
}

public final class FetchDiariesUseCase: FetchDiariesUseCaseProtocol {
    private let repository: DiaryRepositoryProtocol

    public init(repository: DiaryRepositoryProtocol) {
        self.repository = repository
    }

    public func execute() async throws -> [Diary] {
        try await repository.fetchDiaries()
    }
}

