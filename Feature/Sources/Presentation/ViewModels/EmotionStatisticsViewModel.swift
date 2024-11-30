import Foundation
import Core
//import SwiftUI

@MainActor
public final class EmotionStatisticsViewModel: ObservableObject {
    @Published private(set) var statistics: EmotionStatistics?
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    private let repository: DiaryRepository
    
    public init(repository: DiaryRepository) {
        self.repository = repository
        Task { @MainActor in
            await loadStatistics()
        }
    }
    
    public func loadStatistics() async {
        isLoading = true
        error = nil
        
        do {
            let diaries = try await repository.getDiaries()
            let interval = selectedPeriod.dateInterval
            let filteredDiaries = diaries.filter { interval.contains($0.date) }
            
            let emotions = filteredDiaries.reduce(into: [:]) { counts, diary in
                counts[diary.emotion, default: 0] += 1
            }
            
            let emotionStats = emotions.map { emotion, count in
                EmotionStatistics.Emotion(
                    name: emotion,
                    count: count
                )
            }
            .sorted { $0.count > $1.count }
            
            statistics = EmotionStatistics(emotions: emotionStats, startDate: interval.start, endDate: interval.end)
            
            Logger.d("Fetched statistics for period: \(selectedPeriod.rawValue)")
            Logger.d("Total diaries: \(statistics?.totalCount ?? 0)")
            Logger.d("Most frequent emotion: \(statistics?.mostFrequentEmotion ?? "none")")
        } catch {
            Logger.e("Failed to fetch statistics: \(error)")
            self.error = error
        }
        
        isLoading = false
    }
    
    public enum StatisticsPeriod: String, CaseIterable {
        case week = "일주일"
        case month = "한달"
        case year = "일년"
        
        var dateInterval: DateInterval {
            let now = Date()
            let calendar = Calendar.current
            
            switch self {
            case .week:
                let startDate = calendar.date(byAdding: .day, value: -7, to: now)!
                return DateInterval(start: startDate, end: now)
            case .month:
                let startDate = calendar.date(byAdding: .month, value: -1, to: now)!
                return DateInterval(start: startDate, end: now)
            case .year:
                let startDate = calendar.date(byAdding: .year, value: -1, to: now)!
                return DateInterval(start: startDate, end: now)
            }
        }
    }
    
    public var selectedPeriod: StatisticsPeriod = .week
}

private actor PreviewDiaryRepository: DiaryRepository {
    func getDiaries() async throws -> [Diary] {
        return [
            Diary(title: "행복한 하루", content: "행복한 하루", emotion: "행복"),
            Diary(title: "즐거운 하루", content: "즐거운 하루", emotion: "기쁨"),
            Diary(title: "평온한 하루", content: "평온한 하루", emotion: "평온"),
            Diary(title: "우울한 하루", content: "우울한 하루", emotion: "슬픔"),
            Diary(title: "화난 하루", content: "화난 하루", emotion: "분노"),
            Diary(title: "불안한 하루", content: "불안한 하루", emotion: "불안"),
            Diary(title: "희망찬 하루", content: "희망찬 하루", emotion: "희망")
        ]
    }
    
    func saveDiary(_ diary: Diary) async throws {}
    func updateDiary(_ diary: Diary) async throws {}
    func deleteDiary(_ diary: Diary) async throws {}
}
