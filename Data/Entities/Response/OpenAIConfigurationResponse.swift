import Foundation

struct OpenAIConfigurationResponse: Decodable {
    let model: String
    let prompt: String
    let systemContent: String
    let temperature: Double
}
