import Foundation

public protocol DeleteDiaryUseCaseProtocol {
    func execute(diary: Diary) async throws
}

public final class DeleteDiaryUseCase: DeleteDiaryUseCaseProtocol {
    let repository: DiaryRepositoryProtocol
    
    public init(repository: DiaryRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(diary: Diary) async throws {
        try await repository.deleteDiary(diary: diary)
    }
}
