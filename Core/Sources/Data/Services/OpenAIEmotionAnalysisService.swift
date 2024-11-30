import Foundation
import Alamofire

public final class OpenAIEmotionAnalysisService: EmotionAnalysisService {
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
    
    public func analyzeEmotion(from content: String) async throws -> String {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]
        
        let prompt = """
        다음 일기 내용에서 감정을 분석해주세요. 
        감정은 다음 중 하나를 선택해주세요: 행복, 기쁨, 평온, 슬픔, 분노, 불안, 희망
        일기 내용만 분석하고 선택한 감정 하나만 답변해주세요.
        
        일기 내용: "\(content)"
        """
        
        let parameters: Parameters = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "당신은 감정 분석 전문가입니다. 주어진 텍스트에서 가장 두드러진 감정을 파악하고 한 단어로 답변해주세요."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7,
            "max_tokens": 10
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
            .responseData { response in
                Logger.d("Response status code: \(String(describing: response.response?.statusCode))")
                if let data = response.data, let str = String(data: data, encoding: .utf8) {
                    Logger.d("Response data: \(str)")
                }
                
                switch response.result {
                case .success(let data):
                    do {
                        let result = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                        if let emotion = result.choices.first?.message.content.trimmingCharacters(in: .whitespacesAndNewlines) {
                            Logger.d("Successfully analyzed emotion: \(emotion)")
                            continuation.resume(returning: emotion)
                        } else {
                            Logger.e("Failed to extract emotion from response")
                            continuation.resume(throwing: EmotionAnalysisError.invalidResponse)
                        }
                    } catch {
                        Logger.e("Failed to decode response: \(error)")
                        continuation.resume(throwing: EmotionAnalysisError.invalidResponse)
                    }
                case .failure(let error):
                    Logger.e("Request failed: \(error)")
                    if let statusCode = response.response?.statusCode {
                        switch statusCode {
                        case 401, 403:
                            Logger.e("Authentication error: Invalid API key")
                            continuation.resume(throwing: EmotionAnalysisError.invalidAPIKey)
                        default:
                            Logger.e("Network error with status code: \(statusCode)")
                            continuation.resume(throwing: EmotionAnalysisError.networkError(error))
                        }
                    } else {
                        continuation.resume(throwing: EmotionAnalysisError.networkError(error))
                    }
                }
            }
        }
    }
}

private struct OpenAIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
    }
    
    struct Message: Codable {
        let content: String
    }
}
