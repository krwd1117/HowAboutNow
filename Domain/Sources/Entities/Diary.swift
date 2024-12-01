import Foundation

public struct Diary: Identifiable, Codable, Hashable, Sendable {
    public var id: String
    public var title: String
    public var content: String
    public var emotion: String
    public var summary: String
    public var date: Date
    
    public init(
        id: String = UUID().uuidString,
        title: String,
        content: String,
        emotion: String = "",
        summary: String = "",
        date: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.emotion = emotion
        self.summary = summary
        self.date = date
    }
}

extension Diary {
    public var identifier: String {
        id
    }
}
