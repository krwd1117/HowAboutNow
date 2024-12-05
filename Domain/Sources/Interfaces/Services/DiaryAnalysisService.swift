import Foundation

public protocol DiaryAnalysisService {
    func analyzeDiary(content: String) async throws -> DiaryAnalysis
}

public struct DiaryAnalysis {
    public let emotion: String
    public let summary: String
    
    public init(emotion: String, summary: String) {
        self.emotion = emotion
        self.summary = summary
    }
}
