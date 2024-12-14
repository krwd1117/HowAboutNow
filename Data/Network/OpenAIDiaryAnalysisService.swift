import Foundation
import Domain

public protocol OpenAIServiceProtocol {
    func analyzeDiary(content: String) async throws -> DiaryAnalysis
}

public class OpenAIService: OpenAIServiceProtocol {
    private var apiKey: String
    private var baseURL: String
    private let networkService: NetworkServiceProtocol
    
    public init(
        networkService: NetworkServiceProtocol = NetworkService()
    ) {
        let config = ConfigurationManager.shared
        do {
            self.apiKey = try config.string(for: ConfigurationManager.Keys.openAIAPIKey)
            self.baseURL = try config.string(for: ConfigurationManager.Keys.openAIEndpoint)
        } catch {
            self.apiKey = ""
            self.baseURL = ""
        }
        self.networkService = networkService
    }
    
    public func analyzeDiary(content: String) async throws -> DiaryAnalysis {
        let model = "gpt-3.5-turbo" // 사용 모델
        let temperature: Double = 0.7 // 응답의 창의성 설정

        let prompt = """
        Analyze the diary entry below:

        Diary: "\(content)"

        Tasks:
        1. Identify the main emotion: happy, joy, peaceful, sad, angry, anxious, hopeful.
        2. Write a one-sentence summary in the same language as the diary. If the diary is in Korean, the summary must be in Korean.

        Response format:
        {
            "emotion": "selected emotion",
            "summary": "summary"
        }
        """


        let systemContent = """
        You are an assistant for analyzing diary entries. If the diary is written in Korean, provide the summary in Korean. If written in another language, use that language. Identify the main emotion and summarize the diary entry in one sentence. Do not include translations or additional explanations (e.g., parentheses). Respond naturally.
        """


        let parameters: [String: Any] = [
            "model": model,
            "messages": [
                [
                    "role": "system",
                    "content": systemContent
                ],
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "temperature": temperature
        ]
        
        let endpoint = OpenAIEndpoint(
            url: baseURL,
            method: .post,
            parameters: parameters,
            headers: [
                "Authorization": "Bearer \(apiKey)",
                "Content-Type": "application/json"
            ]
        )
        
        let response: OpenAIResponse = try await NetworkService().request(endpoint)
            
        guard let content = response.choices.first?.message.content,
              let data = content.data(using: .utf8) else {
            throw NSError(
                domain: "OpenAIDiaryAnalysisService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No response received"]
            )
        }
        
        do {
            let analysis = try JSONDecoder().decode(AnalysisResponse.self, from: data)
            return DiaryAnalysis(emotion: analysis.emotion, summary: analysis.summary)
        } catch {
            throw NSError(
                domain: "OpenAIDiaryAnalysisService",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "Invalid response format"]
            )
        }
    }
}

