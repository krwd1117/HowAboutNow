import SwiftUI
import Core
import Charts

public struct EmotionStatisticsView: View {
    @State private var viewModel: EmotionStatisticsViewModel
    
    public init(viewModel: EmotionStatisticsViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                periodSelector
                
                if let statistics = viewModel.statistics {
                    summarySection(statistics)
                    chartSection(statistics)
                    detailSection(statistics)
                } else {
                    ContentUnavailableView("통계 없음", 
                        systemImage: "chart.pie",
                        description: Text("아직 작성된 일기가 없습니다")
                    )
                }
            }
            .padding()
        }
        .navigationTitle("감정 통계")
        .task {
            await viewModel.fetchStatistics()
        }
    }
    
    private var periodSelector: some View {
        Picker("기간", selection: $viewModel.selectedPeriod) {
            ForEach(EmotionStatisticsViewModel.StatisticsPeriod.allCases, id: \.self) { period in
                Text(period.rawValue).tag(period)
            }
        }
        .pickerStyle(.segmented)
        .onChange(of: viewModel.selectedPeriod) {
            Task {
                await viewModel.fetchStatistics()
            }
        }
    }
    
    private func summarySection(_ statistics: EmotionStatistics) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("요약")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("전체 일기")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("\(statistics.totalCount)개")
                        .font(.title2)
                        .bold()
                }
                
                Spacer()
                
                if let mostFrequent = statistics.mostFrequentEmotion {
                    VStack(alignment: .trailing) {
                        Text("가장 많은 감정")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(mostFrequent)
                            .font(.title2)
                            .bold()
                    }
                }
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
    
    private func chartSection(_ statistics: EmotionStatistics) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("감정 분포")
                .font(.headline)
            
            if #available(iOS 17.0, *) {
                Chart(statistics.counts, id: \.emotion) { item in
                    SectorMark(
                        angle: .value("비율", Double(item.count)),
                        innerRadius: .ratio(0.618),
                        angularInset: 1.5
                    )
                    .foregroundStyle(by: .value("감정", item.emotion))
                }
                .frame(height: 200)
            } else {
                Text("iOS 17 이상에서 차트를 확인할 수 있습니다")
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private func detailSection(_ statistics: EmotionStatistics) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("상세 통계")
                .font(.headline)
            
            ForEach(statistics.counts, id: \.emotion) { item in
                HStack {
                    Text(item.emotion)
                        .frame(width: 80, alignment: .leading)
                    
                    GeometryReader { geometry in
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.accentColor.opacity(0.2))
                            .frame(width: geometry.size.width * item.percentage / 100)
                            .overlay(alignment: .leading) {
                                Text("\(item.count)회 (\(Int(item.percentage))%)")
                                    .font(.caption)
                                    .padding(.leading, 8)
                            }
                    }
                }
                .frame(height: 30)
            }
        }
    }
}

#Preview {
    NavigationStack {
        EmotionStatisticsView(viewModel: EmotionStatisticsViewModel(repository: MockDiaryRepository()))
    }
}

private class MockDiaryRepository: DiaryRepository {
    func getDiaries() async throws -> [Diary] {
        return [
            Diary(content: "행복한 하루", emotion: "행복"),
            Diary(content: "즐거운 하루", emotion: "기쁨"),
            Diary(content: "평온한 하루", emotion: "평온"),
            Diary(content: "우울한 하루", emotion: "슬픔"),
            Diary(content: "화난 하루", emotion: "분노"),
            Diary(content: "불안한 하루", emotion: "불안"),
            Diary(content: "희망찬 하루", emotion: "희망"),
        ]
    }
    
    func saveDiary(_ diary: Diary) async throws {}
    func updateDiary(_ diary: Diary) async throws {}
    func deleteDiary(_ diary: Diary) async throws {}
}
