import Foundation
import SwiftData

public final class DiaryDataRepository {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    public init() throws {
        let schema = Schema([Diary.self])
        let modelConfiguration = ModelConfiguration(schema: schema)
        
        do {
            modelContainer = try ModelContainer(for: schema)
            modelContext = ModelContext(modelContainer)
            modelContext.autosaveEnabled = true
        } catch {
            throw error
        }
    }
}

extension DiaryDataRepository: DiaryRepository {
    public func getDiaries() async throws -> [Diary] {
        let descriptor = FetchDescriptor<Diary>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        return try modelContext.fetch(descriptor)
    }
    
    public func saveDiary(_ diary: Diary) async throws {
        modelContext.insert(diary)
        try modelContext.save()
    }
    
    public func updateDiary(_ diary: Diary) async throws {
        try modelContext.save()
    }
    
    public func deleteDiary(_ diary: Diary) async throws {
        modelContext.delete(diary)
        try modelContext.save()
    }
}
