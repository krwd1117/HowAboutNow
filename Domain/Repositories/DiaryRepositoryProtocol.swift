import Foundation

public protocol DiaryRepositoryProtocol {
    func fetchDiaries() async throws -> [Diary]
    func addDiary(diary: Diary) async throws
    func updateDiary(diary: Diary) async throws
    func deleteDiary(diary: Diary) async throws
    func analyzeDiary(diary: Diary) async throws -> DiaryAnalysis
}
