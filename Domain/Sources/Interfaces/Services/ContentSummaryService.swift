import Foundation

public protocol ContentSummaryService: Actor {
    func summarize(_ content: String) async throws -> String
}

public enum ContentSummaryError: Error {
    case invalidAPIKey
    case invalidResponse
    case networkError(Error)
}
