import Foundation

public protocol FetchDiaryUseCaseProtocol {
    func execute() async throws -> [Diary]
}

public final class FetchDiaryUseCase: FetchDiaryUseCaseProtocol {
    private let repository: DiaryRepositoryProtocol

    public init(repository: DiaryRepositoryProtocol) {
        self.repository = repository
    }

    public func execute() async throws -> [Diary] {
        try await repository.fetchDiaries()
    }
}

