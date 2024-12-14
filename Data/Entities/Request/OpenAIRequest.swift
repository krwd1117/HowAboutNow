import Foundation

struct OpenAIRequest: Encodable {
    let model: String
    let messages: [Message]
    let temperature: Double
    let maxTokens: Int
    
    struct Message: Encodable {
        let role: String
        let content: String
    }
    
    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case temperature
        case maxTokens = "max_tokens"
    }
}
