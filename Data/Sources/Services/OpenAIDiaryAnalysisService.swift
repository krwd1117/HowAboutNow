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
        Please analyze the following diary entry:
        
        Diary: "\(content)"
        
        1. Choose one emotion that best describes the overall feeling from this diary entry: happy, joy, peaceful, sad, angry, anxious, hopeful
        2. Summarize the diary content in one sentence using the same language as the diary entry.
        
        Please respond in the following JSON format:
        {
            "emotion": "selected_emotion",
            "summary": "one_sentence_summary"
        }
        """
        
        let parameters: [String: Any] = [
            "model": "gpt-4",
            "messages": [
                [
                    "role": "system",
                    "content": """
                        You are a diary analysis expert.
                        Analyze the diary content to identify the writer's emotions and provide a brief summary.
                        Always respond in the specified JSON format.
                        """
                ],
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "temperature": 0.7
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(
                baseURL,
                method: .post,
                parameters: parameters,
                encoding: JSONEncoding.default,
                headers: headers
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
