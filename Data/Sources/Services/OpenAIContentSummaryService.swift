import Foundation
import Alamofire
import Domain
import Infrastructure

public actor OpenAIContentSummaryService: ContentSummaryService {
    private let apiKey: String
    private let baseURL: String
    
    public init(apiKey: String) {
        self.apiKey = apiKey
        do {
            self.baseURL = try ConfigurationManager.shared.string(for: ConfigurationManager.Keys.openAIEndpoint)
        } catch {
            self.baseURL = "https://api.openai.com/v1/chat/completions" // 기본값
        }
        Logger.d("OpenAI Service initialized with API key: \(String(apiKey.prefix(10)))...")
    }
    
    public func summarize(_ content: String) async throws -> String {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]
        
        let prompt = """
        다음 일기 내용을 한 문장으로 요약해주세요. 요약할 때는 가장 중요한 감정이나 사건을 중심으로 해주세요:
        
        일기 내용: "\(content)"
        """
        
        let parameters: Parameters = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "당신은 일기를 요약하는 전문가입니다. 일기의 핵심 내용을 한 문장으로 요약해주세요."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7,
            "max_tokens": 100
        ]
        
        Logger.d("Making OpenAI request to: \(baseURL)")
        Logger.d("Headers: \(headers)")
        Logger.d("Parameters: \(parameters)")
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(
                baseURL,
                method: .post,
                parameters: parameters,
                encoding: JSONEncoding.default,
                headers: headers
            )
            .validate()
            .responseDecodable(of: OpenAIResponse.self) { response in
                Logger.d("Response status code: \(String(describing: response.response?.statusCode))")
                if let data = response.data, let str = String(data: data, encoding: .utf8) {
                    Logger.d("Response data: \(str)")
                }
                
                switch response.result {
                case .success(let result):
                    if let summary = result.choices.first?.message.content.trimmingCharacters(in: .whitespacesAndNewlines) {
                        Logger.d("Successfully summarized content: \(summary)")
                        continuation.resume(returning: summary)
                    } else {
                        Logger.e("Failed to extract summary from response")
                        continuation.resume(throwing: ContentSummaryError.invalidResponse)
                    }
                case .failure(let error):
                    Logger.e("Request failed: \(error)")
                    if let statusCode = response.response?.statusCode {
                        switch statusCode {
                        case 401, 403:
                            Logger.e("Authentication error: Invalid API key")
                            continuation.resume(throwing: ContentSummaryError.invalidAPIKey)
                        default:
                            Logger.e("Network error with status code: \(statusCode)")
                            continuation.resume(throwing: ContentSummaryError.networkError(error))
                        }
                    } else {
                        continuation.resume(throwing: ContentSummaryError.networkError(error))
                    }
                }
            }
        }
    }
}
