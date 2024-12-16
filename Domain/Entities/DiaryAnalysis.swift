import Foundation

public struct DiaryAnalysis {
    public let title: String
    public let emotion: String
    public let summary: String
    
    public init(title: String, emotion: String, summary: String) {
        self.title = title
        self.emotion = emotion
        self.summary = summary
    }
}
