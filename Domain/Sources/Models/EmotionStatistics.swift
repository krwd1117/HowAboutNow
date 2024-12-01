import Foundation

public struct EmotionStatistics {
    public struct Emotion: Identifiable {
        public let id = UUID()
        public let name: String
        public let count: Int
        
        public init(name: String, count: Int) {
            self.name = name
            self.count = count
        }
    }
    
    public let emotions: [Emotion]
    public let totalCount: Int
    public let startDate: Date
    public let endDate: Date
    
    public init(emotions: [Emotion], startDate: Date, endDate: Date) {
        self.emotions = emotions
        self.totalCount = emotions.reduce(0) { $0 + $1.count }
        self.startDate = startDate
        self.endDate = endDate
    }
    
    public var mostFrequentEmotion: String? {
        emotions.max(by: { $0.count < $1.count })?.name
    }
}
