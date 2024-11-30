import Foundation
import Core
import SwiftUI

@Observable
public class EmotionStatisticsViewModel {
    private let repository: DiaryRepository
    public var statistics: EmotionStatistics?
    public var selectedPeriod: StatisticsPeriod = .week
    public var error: Error?
    
    public enum StatisticsPeriod: String, CaseIterable {
        case week = "일주일"
        case month = "한달"
        case year = "일년"
        
        var dateInterval: DateInterval {
            let now = Date()
            let calendar = Calendar.current
            
            switch self {
            case .week:
                let startDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
                return DateInterval(start: startDate, end: now)
            case .month:
                let startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
                return DateInterval(start: startDate, end: now)
            case .year:
                let startDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
                return DateInterval(start: startDate, end: now)
            }
        }
    }
    
    public init(repository: DiaryRepository) {
        self.repository = repository
        Task { @MainActor in
            await fetchStatistics()
        }
    }
    
    @MainActor
    public func fetchStatistics() async {
        do {
            let interval = selectedPeriod.dateInterval
            let diaries = try await repository.getDiaries()
            let filteredDiaries = diaries.filter { interval.contains($0.date) }
            
            statistics = EmotionStatistics(
                diaries: filteredDiaries,
                startDate: interval.start,
                endDate: interval.end
            )
            
            Logger.d("Fetched statistics for period: \(selectedPeriod.rawValue)")
            Logger.d("Total diaries: \(statistics?.totalCount ?? 0)")
            Logger.d("Most frequent emotion: \(statistics?.mostFrequentEmotion ?? "none")")
        } catch {
            Logger.e("Failed to fetch statistics: \(error)")
            self.error = error
        }
    }
}
