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
            VStack(spacing: 24) {
                if let statistics = viewModel.statistics {
                    periodPicker
                    
                    if let mostFrequent = statistics.mostFrequentEmotion {
                        mostFrequentEmotionCard(emotion: mostFrequent)
                    }
                    
                    EmotionPieChart(statistics: statistics)
                        .frame(height: 240)
                    
                    EmotionBarChart(statistics: statistics)
                        .frame(height: 200)
                    
                    EmotionList(statistics: statistics)
                }
            }
            .padding()
        }
        .navigationTitle("감정 통계")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.loadStatistics()
        }
        .onChange(of: viewModel.selectedPeriod) { _, _ in
            Task {
                await viewModel.loadStatistics()
            }
        }
    }
    
    private var periodPicker: some View {
        Picker("기간", selection: $viewModel.selectedPeriod) {
            ForEach(EmotionStatisticsViewModel.StatisticsPeriod.allCases, id: \.self) { period in
                Text(period.rawValue).tag(period)
            }
        }
        .pickerStyle(.segmented)
    }
    
    private func mostFrequentEmotionCard(emotion: String) -> some View {
        VStack(spacing: 8) {
            Text("가장 많이 느낀 감정")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            EmotionBadge(emotion: emotion)
                .scaleEffect(1.2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        }
    }
}

private struct EmotionPieChart: View {
    let statistics: EmotionStatistics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("감정 분포")
                .font(.headline)
            
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
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        }
    }
}

private struct EmotionBarChart: View {
    let statistics: EmotionStatistics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("감정별 횟수")
                .font(.headline)
            
            Chart(statistics.emotions) { emotion in
                BarMark(
                    x: .value("Emotion", emotion.name),
                    y: .value("Count", emotion.count)
                )
                .cornerRadius(4)
                .foregroundStyle(by: .value("Emotion", emotion.name))
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
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        }
    }
}

private struct EmotionList: View {
    let statistics: EmotionStatistics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("감정 목록")
                .font(.headline)
            
            ForEach(statistics.emotions) { emotion in
                HStack {
                    EmotionBadge(emotion: emotion.name)
                    Spacer()
                    Text("\(emotion.count)회")
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        }
    }
}

private struct EmotionBadge: View {
    let emotion: String
    
    var emoji: String {
        switch emotion {
        case "행복": return "😊"
        case "기쁨": return "😄"
        case "평온": return "😌"
        case "슬픔": return "😢"
        case "분노": return "😠"
        case "불안": return "😰"
        case "희망": return "🥰"
        default: return "🤔"
        }
    }
    
    var color: Color {
        switch emotion {
        case "행복", "기쁨": return .yellow
        case "평온": return .mint
        case "슬픔": return .blue
        case "분노": return .red
        case "불안": return .purple
        case "희망": return .pink
        default: return .gray
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Text(emoji)
            Text(emotion)
                .font(.caption.bold())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .foregroundStyle(color)
        .clipShape(Capsule())
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
            Diary(title: "행복한 하루", content: "행복한 하루", emotion: "행복"),
            Diary(title: "즐거운 하루", content: "즐거운 하루", emotion: "기쁨"),
            Diary(title: "평온한 하루",content: "평온한 하루", emotion: "평온"),
            Diary(title: "우울한 하루",content: "우울한 하루", emotion: "슬픔"),
            Diary(title: "화난 하루",content: "화난 하루", emotion: "분노"),
            Diary(title: "불안한 하루",content: "불안한 하루", emotion: "불안"),
            Diary(title: "희망찬 하루",content: "희망찬 하루", emotion: "희망")
        ]
    }
    
    func saveDiary(_ diary: Diary) async throws {}
    func updateDiary(_ diary: Diary) async throws {}
    func deleteDiary(_ diary: Diary) async throws {}
}
