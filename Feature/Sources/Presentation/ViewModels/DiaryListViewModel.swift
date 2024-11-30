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
        Task { @MainActor in
            await fetchDiaries()
        }
    }
    
    @MainActor
    public func fetchDiaries() async {
        do {
            diaries = try await repository.getDiaries()
            print("Fetched \(diaries.count) diaries")
        } catch {
            self.error = error
            print("Failed to fetch diaries: \(error)")
        }
    }
    
    @MainActor
    public func addDiary(content: String) async {
        let diary = Diary(content: content, emotion: "") // 감정은 나중에 GPT로 분석
        do {
            try await repository.saveDiary(diary)
            await fetchDiaries()
            print("Successfully added new diary")
        } catch {
            self.error = error
            print("Failed to add diary: \(error)")
        }
    }
    
    @MainActor
    public func updateDiary(_ diary: Diary, content: String) async {
        diary.content = content
        diary.date = .now // 수정 시간 업데이트
        
        do {
            try await repository.updateDiary(diary)
            await fetchDiaries()
            print("Successfully updated diary: \(diary.id)")
        } catch {
            self.error = error
            print("Failed to update diary: \(error)")
        }
    }
    
    @MainActor
    public func deleteDiaries(at indexSet: IndexSet) async {
        for index in indexSet {
            let diary = diaries[index]
            do {
                try await repository.deleteDiary(diary)
                print("Successfully deleted diary: \(diary.id)")
            } catch {
                self.error = error
                print("Failed to delete diary: \(diary.id)")
            }
        }
        await fetchDiaries()
    }
}
