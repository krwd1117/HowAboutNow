import Foundation
import Domain
import Infrastructure

public actor DiaryDataRepository: DiaryRepository {
    private let userDefaults: UserDefaults
    private let diaryKey = "com.krwd.howaboutnow.diaries"
    
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    public func getDiaries() async throws -> [Diary] {
        guard let data = userDefaults.data(forKey: diaryKey) else {
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let diaries = try decoder.decode([Diary].self, from: data)
            return diaries.sorted { $0.date > $1.date }
        } catch {
            // 이전 버전의 데이터 구조와 호환성 유지
            if let decodingError = error as? DecodingError,
               case .keyNotFound(let key, _) = decodingError,
               key.stringValue == "title" {
                // 기존 데이터 삭제
                userDefaults.removeObject(forKey: self.diaryKey)
                return []
            }
            Logger.e("Failed to decode diaries: \(error)")
            throw RepositoryError.databaseError(error)
        }
    }
    
    public func saveDiary(_ diary: Diary) async throws {
        var diaries = try await getDiaries()
        diaries.append(diary)
        try saveDiaries(diaries)
    }
    
    public func updateDiary(_ diary: Diary) async throws {
        var diaries = try await getDiaries()
        if let index = diaries.firstIndex(where: { $0.id == diary.id }) {
            diaries[index] = diary
            try saveDiaries(diaries)
        }
    }
    
    public func deleteDiary(_ diary: Diary) async throws {
        var diaries = try await getDiaries()
        diaries.removeAll { $0.id == diary.id }
        try saveDiaries(diaries)
    }
    
    private func saveDiaries(_ diaries: [Diary]) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        do {
            let data = try encoder.encode(diaries)
            userDefaults.set(data, forKey: diaryKey)
        } catch {
            Logger.e("Failed to encode diaries: \(error)")
            throw RepositoryError.databaseError(error)
        }
    }
}

extension DiaryDataRepository {
    enum RepositoryError: Error {
        case invalidDiary
        case databaseError(Error)
    }
}
