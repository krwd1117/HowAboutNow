import Foundation

public protocol UpdateDiaryUseCaseProtocol {
    func execute(diary: Diary) async throws
}

public final class UpdateDiaryUseCase: UpdateDiaryUseCaseProtocol {
    private let repository: DiaryRepositoryProtocol
    
    public init(repository: DiaryRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(diary: Diary) async throws {
        try await repository.updateDiary(diary: diary)
    }
}
