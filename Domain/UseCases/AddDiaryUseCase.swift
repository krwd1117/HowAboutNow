import Foundation

enum ValidationError: Error {
    case emptyContent
}

public protocol AddDiaryUseCaseProtocol {
    func execute(diary: Diary) async throws
}


public final class AddDiaryUseCase: AddDiaryUseCaseProtocol {
    private let repository: DiaryRepositoryProtocol

    public init(repository: DiaryRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(diary: Diary) async throws {
        // 비즈니스 로직: 중복 확인, 날짜 검증 등
        if diary.content.isEmpty { throw ValidationError.emptyContent }
        
        try await repository.addDiary(diary: diary)
    }
}

