import Foundation

public protocol AnalysisDiaryUseCaseProtocol {
    func excute(content: String) async throws -> DiaryAnalysis?
}

public final class AnalysisDiaryUseCase: AnalysisDiaryUseCaseProtocol {
    
    let repository: DiaryRepositoryProtocol
    
    public init(repository: DiaryRepositoryProtocol) {
        self.repository = repository
    }
    
    public func excute(content: String) async throws -> DiaryAnalysis? {
        return nil
    }
}
