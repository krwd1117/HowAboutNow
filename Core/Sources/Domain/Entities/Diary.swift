import Foundation
import SwiftData

@Model
public class Diary {
    public var id: UUID
    public var date: Date
    public var content: String
    public var emotion: String
    
    public init(id: UUID = UUID(), date: Date = .now, content: String, emotion: String) {
        self.id = id
        self.date = date
        self.content = content
        self.emotion = emotion
    }
}
