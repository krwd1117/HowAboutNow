import SwiftUI
import Core
import Charts

public struct EmotionStatisticsView: View {
    @State private var viewModel: EmotionStatisticsViewModel
    
    public init(viewModel: EmotionStatisticsViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let statistics = viewModel.statistics {
                    EmotionPieChart(statistics: statistics)
                    EmotionBarChart(statistics: statistics)
                    EmotionList(statistics: statistics)
                }
            }
            .padding()
        }
        .navigationTitle("감정 통계")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Picker("기간", selection: $viewModel.selectedPeriod) {
                    ForEach(EmotionStatisticsViewModel.StatisticsPeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
            }
        }
        .task {
            await viewModel.loadStatistics()
        }
        .onChange(of: viewModel.selectedPeriod) { _, _ in
            Task {
                await viewModel.loadStatistics()
            }
        }
    }
}

private struct EmotionPieChart: View {
    let statistics: EmotionStatistics
    
    var body: some View {
        Chart(statistics.emotions) { emotion in
            SectorMark(
                angle: .value("Count", emotion.count),
                innerRadius: .ratio(0.618),
                angularInset: 1.5
            )
            .cornerRadius(3)
            .foregroundStyle(by: .value("Emotion", emotion.name))
        }
        .chartLegend(.visible)
        .frame(height: 200)
    }
}

private struct EmotionBarChart: View {
    let statistics: EmotionStatistics
    
    var body: some View {
        Chart(statistics.emotions) { emotion in
            BarMark(
                x: .value("Emotion", emotion.name),
                y: .value("Count", emotion.count)
            )
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                AxisValueLabel {
                    if let name = value.as(String.self) {
                        Text(name)
                            .rotationEffect(.degrees(-45))
                    }
                }
            }
        }
        .frame(height: 200)
    }
}

private struct EmotionList: View {
    let statistics: EmotionStatistics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("감정 목록")
                .font(.headline)
            
            ForEach(statistics.emotions) { emotion in
                HStack {
                    Text(emotion.name)
                    Spacer()
                    Text("\(emotion.count)회")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        EmotionStatisticsView(viewModel: EmotionStatisticsViewModel(repository: MockDiaryRepository()))
    }
}

private actor MockDiaryRepository: DiaryRepository {
    func getDiaries() async throws -> [Diary] {
        return [
            Diary(content: "행복한 하루", emotion: "행복"),
            Diary(content: "즐거운 하루", emotion: "기쁨"),
            Diary(content: "평온한 하루", emotion: "평온"),
            Diary(content: "우울한 하루", emotion: "슬픔"),
            Diary(content: "화난 하루", emotion: "분노"),
            Diary(content: "불안한 하루", emotion: "불안"),
            Diary(content: "희망찬 하루", emotion: "희망")
        ]
    }
    
    func saveDiary(_ diary: Diary) async throws {}
    func updateDiary(_ diary: Diary) async throws {}
    func deleteDiary(_ diary: Diary) async throws {}
}
