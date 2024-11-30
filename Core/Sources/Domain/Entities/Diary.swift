import Foundation

public struct Diary: Identifiable, Codable, Sendable {
    public var id: String
    public var content: String
    public var emotion: String
    public var date: Date
    
    public init(id: String = UUID().uuidString, content: String, emotion: String, date: Date = Date()) {
        self.id = id
        self.content = content
        self.emotion = emotion
        self.date = date
    }
}

extension Diary {
    public var identifier: String {
        id
    }
}
