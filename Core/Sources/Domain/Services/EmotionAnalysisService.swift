import Foundation

public protocol EmotionAnalysisService {
    func analyzeEmotion(from content: String) async throws -> String
}

public enum EmotionAnalysisError: Error {
    case invalidAPIKey
    case invalidResponse
    case networkError(Error)
}
