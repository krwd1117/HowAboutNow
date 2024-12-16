import Foundation

public struct OpenAIConfiguration {
    public let model: String
    public let prompt: String
    public let systemContent: String
    public let temperature: Double

    public init(model: String, prompt: String, systemContent: String, temperature: Double) {
        self.model = model
        self.prompt = prompt
        self.systemContent = systemContent
        self.temperature = temperature
    }
}
