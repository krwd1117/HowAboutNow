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
        Analyze the given diary entry and provide the following information:

        Diary content: "\(content)"

        Instructions:
        1. Identify the main emotion from this list: happy, joy, peaceful, sad, angry, anxious, hopeful.
        2. Write a one-sentence summary of the diary entry in the same language as the diary content. Use a natural and empathetic tone.

        Response format:
        {
            "emotion": "selected emotion",
            "summary": "one-sentence summary in the diary's language"
        }
        """

        
        let parameters: [String: Any] = [
            "model": "gpt-3.5-turbo", // 사용할 OpenAI 모델
            "messages": [
                [
                    "role": "system",
                    "content": """
                    You are an assistant analyzing diary entries. Your goal is to:
                    - Respond with a natural and empathetic tone.
                    - Match the language of the diary entry.
                    """
                ],
                [
                    "role": "user",
                    "content": prompt // 유저가 제공하는 프롬프트
                ]
            ],
            "temperature": 0.7 // 응답의 창의성 설정
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
