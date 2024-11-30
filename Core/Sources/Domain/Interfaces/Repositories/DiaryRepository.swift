import Foundation

public protocol DiaryRepository: Actor {
    func getDiaries() async throws -> [Diary]
    func saveDiary(_ diary: Diary) async throws
    func updateDiary(_ diary: Diary) async throws
    func deleteDiary(_ diary: Diary) async throws
}
