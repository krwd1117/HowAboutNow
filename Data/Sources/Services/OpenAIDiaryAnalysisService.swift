import Foundation
import Domain
import Alamofire
import Infrastructure

public actor OpenAIDiaryAnalysisService: DiaryAnalysisService {
    private let apiKey: String
    private let baseURL: String
    
    public init() throws {
        let config = ConfigurationManager.shared
        self.apiKey = try config.string(for: ConfigurationManager.Keys.openAIAPIKey)
        self.baseURL = try config.string(for: ConfigurationManager.Keys.openAIEndpoint)
    }
    
    public func analyzeDiary(content: String) async throws -> DiaryAnalysis {
        let prompt = """
        Analyze this diary:
        
        Diary: "\(content)"
        
        1. Choose emotion: happy, joy, peaceful, sad, angry, anxious, hopeful
        2. Summarize in ONE sentence using the SAME language as the diary
        
        Format:
        {
            "emotion": "emotion",
            "summary": "summary in diary's language"
        }
        """
        
        let parameters: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                [
                    "role": "system",
                    "content": """
                        Korean diary → Korean summary
                        English diary → English summary
                        Use natural, gentle tone
                        """
                ],
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "temperature": 0.7
        ]
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(
                baseURL,
                method: .post,
                parameters: parameters,
                encoding: JSONEncoding.default,
                headers: [
                    "Authorization": "Bearer \(apiKey)",
                    "Content-Type": "application/json"
                ]
            )
            .responseDecodable(of: OpenAIResponse.self) { response in
                switch response.result {
                case .success(let openAIResponse):
                    if let content = openAIResponse.choices.first?.message.content,
                       let data = content.data(using: .utf8) {
                        do {
                            let analysis = try JSONDecoder().decode(AnalysisResponse.self, from: data)
                            continuation.resume(returning: DiaryAnalysis(
                                emotion: analysis.emotion,
                                summary: analysis.summary
                            ))
                        } catch {
                            continuation.resume(throwing: NSError(
                                domain: "OpenAIDiaryAnalysisService",
                                code: -2,
                                userInfo: [NSLocalizedDescriptionKey: "Invalid response format"]
                            ))
                        }
                    } else {
                        continuation.resume(throwing: NSError(
                            domain: "OpenAIDiaryAnalysisService",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "No response received"]
                        ))
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

private struct AnalysisResponse: Codable {
    let emotion: String
    let summary: String
}
