import Foundation
import SwiftUI
import Core

@Observable
public class DiaryListViewModel {
    private let repository: DiaryRepository
    public var diaries: [Diary] = []
    public var error: Error?
    
    public init(repository: DiaryRepository) {
        self.repository = repository
    }
    
    public func fetchDiaries() {
        Task {
            do {
                diaries = try await repository.getDiaries()
            } catch {
                self.error = error
            }
        }
    }
    
    public func addDiary(content: String, emotion: String) {
        let diary = Diary(content: content, emotion: emotion)
        Task {
            try? await repository.saveDiary(diary)
            await fetchDiaries()
        }
    }
}
