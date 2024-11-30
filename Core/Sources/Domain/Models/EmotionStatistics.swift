import Foundation

public struct EmotionStatistics {
    public struct EmotionCount {
        public let emotion: String
        public let count: Int
        public let percentage: Double
        
        public init(emotion: String, count: Int, total: Int) {
            self.emotion = emotion
            self.count = count
            self.percentage = total > 0 ? Double(count) / Double(total) * 100 : 0
        }
    }
    
    public let counts: [EmotionCount]
    public let totalCount: Int
    public let startDate: Date
    public let endDate: Date
    
    public init(diaries: [Diary], startDate: Date, endDate: Date) {
        let emotionCounts = Dictionary(grouping: diaries) { $0.emotion }
            .filter { !$0.key.isEmpty }
            .map { (emotion, diaries) in
                EmotionCount(emotion: emotion, count: diaries.count, total: diaries.count)
            }
            .sorted { $0.count > $1.count }
        
        self.counts = emotionCounts
        self.totalCount = diaries.count
        self.startDate = startDate
        self.endDate = endDate
    }
    
    public var mostFrequentEmotion: String? {
        counts.first?.emotion
    }
    
    public func countFor(emotion: String) -> Int {
        counts.first { $0.emotion == emotion }?.count ?? 0
    }
    
    public func percentageFor(emotion: String) -> Double {
        counts.first { $0.emotion == emotion }?.percentage ?? 0
    }
}
