import SwiftUI
import Domain
import Infrastructure
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
                        .padding(.horizontal)
                    
                    if let mostFrequent = statistics.mostFrequentEmotion {
                        mostFrequentEmotionCard(emotion: mostFrequent)
                            .padding(.horizontal)
                    }
                    
                    EmotionPieChart(statistics: statistics)
                        .padding(.horizontal)
                    
                    EmotionBarChart(statistics: statistics)
                        .padding(.horizontal)
                    
                    EmotionList(statistics: statistics)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("감정 통계")
        .navigationBarTitleDisplayMode(.inline)
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
        .tint(.pink)
    }
    
    private func mostFrequentEmotionCard(emotion: String) -> some View {
        VStack(spacing: 12) {
            Label {
                Text("가장 많이 느낀 감정")
                    .font(.headline)
            } icon: {
                Image(systemName: "heart.circle.fill")
                    .symbolRenderingMode(.multicolor)
                    .foregroundStyle(.pink)
            }
            
            EmotionBadge(emotion: emotion)
                .scaleEffect(1.2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.03), radius: 8, y: 4)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(.quaternary, lineWidth: 0.5)
        }
    }
}

private struct EmotionPieChart: View {
    let statistics: EmotionStatistics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label {
                Text("감정 분포")
                    .font(.headline)
            } icon: {
                Image(systemName: "chart.pie.fill")
                    .symbolRenderingMode(.multicolor)
                    .foregroundStyle(.pink)
            }
            
            Chart(statistics.emotions) { emotion in
                SectorMark(
                    angle: .value("Count", emotion.count),
                    innerRadius: .ratio(0.618),
                    angularInset: 1.5
                )
                .cornerRadius(4)
                .foregroundStyle(by: .value("Emotion", emotion.name))
            }
            .chartLegend(.visible)
            .frame(height: 240)
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.03), radius: 8, y: 4)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(.quaternary, lineWidth: 0.5)
        }
    }
}

private struct EmotionBarChart: View {
    let statistics: EmotionStatistics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label {
                Text("감정 추이")
                    .font(.headline)
            } icon: {
                Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                    .symbolRenderingMode(.multicolor)
                    .foregroundStyle(.pink)
            }
            
            Chart(statistics.emotions) { emotion in
                BarMark(
                    x: .value("Emotion", emotion.name),
                    y: .value("Count", emotion.count)
                )
                .cornerRadius(4)
                .foregroundStyle(by: .value("Emotion", emotion.name))
            }
            .chartLegend(.hidden)
            .frame(height: 200)
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.03), radius: 8, y: 4)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(.quaternary, lineWidth: 0.5)
        }
    }
}

private struct EmotionList: View {
    let statistics: EmotionStatistics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label {
                Text("감정 순위")
                    .font(.headline)
            } icon: {
                Image(systemName: "list.number.circle.fill")
                    .symbolRenderingMode(.multicolor)
                    .foregroundStyle(.pink)
            }
            
            ForEach(statistics.emotions) { emotion in
                HStack {
                    EmotionBadge(emotion: emotion.name)
                        .scaleEffect(0.9)
                    
                    Spacer()
                    
                    Text("\(emotion.count)회")
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.03), radius: 8, y: 4)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(.quaternary, lineWidth: 0.5)
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
