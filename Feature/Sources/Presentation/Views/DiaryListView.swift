import SwiftUI
import Core

public struct DiaryListView: View {
    @StateObject private var viewModel: DiaryListViewModel
    @State private var showingAddDiarySheet = false
    @State private var selectedDiary: Diary?
    @State private var showingDeleteAlert = false
    @State private var diaryToDelete: Diary?
    
    public init(viewModel: DiaryListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.diaries.isEmpty {
                    ContentUnavailableView {
                        Label("일기가 없습니다", systemImage: "book.closed")
                    } description: {
                        Text("오늘의 감정을 기록해보세요")
                    } actions: {
                        Button(action: { showingAddDiarySheet = true }) {
                            Text("일기 쓰기")
                        }
                        .buttonStyle(.bordered)
                    }
                } else {
                    diaryList
                }
            }
            .navigationTitle("감정 일기")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: EmotionStatisticsView(viewModel: EmotionStatisticsViewModel(repository: viewModel.repository))) {
                        Label("통계", systemImage: "chart.pie.fill")
                            .symbolRenderingMode(.multicolor)
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddDiarySheet = true }) {
                        Label("새 일기", systemImage: "square.and.pencil")
                    }
                }
            }
            .sheet(isPresented: $showingAddDiarySheet) {
                DiaryEditorView { title, content, date in
                    Task {
                        await viewModel.addDiary(title: title, content: content, date: date)
                    }
                }
            }
            .sheet(item: $selectedDiary) { diary in
                DiaryEditorView(
                    title: diary.title,
                    content: diary.content,
                    date: diary.date
                ) { title, content, date in
                    Task {
                        await viewModel.updateDiary(diary, title: title, content: content, date: date)
                    }
                }
            }
            .alert("일기 삭제", isPresented: $showingDeleteAlert) {
                Button("취소", role: .cancel) { }
                Button("삭제", role: .destructive) {
                    if let diary = diaryToDelete {
                        Task {
                            await viewModel.deleteDiary(diary)
                        }
                    }
                }
            } message: {
                Text("정말 삭제하시겠습니까?")
            }
        }
        .task {
            await viewModel.loadDiaries()
        }
    }
    
    private var diaryList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.diaries) { diary in
                    DiaryCell(diary: diary)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedDiary = diary
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                diaryToDelete = diary
                                showingDeleteAlert = true
                            } label: {
                                Label("삭제", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                diaryToDelete = diary
                                showingDeleteAlert = true
                            } label: {
                                Label("삭제", systemImage: "trash")
                            }
                        }
                }
            }
            .padding()
        }
    }
}

private struct DiaryCell: View {
    let diary: Diary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                EmotionBadge(emotion: diary.emotion)
                
                Spacer()
                
                Text(diary.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Text(diary.title)
                .font(.headline)
            
            Text(diary.content)
                .font(.body)
                .lineLimit(3)
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

struct DiaryListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DiaryListView(viewModel: DiaryListViewModel(
                repository: MockDiaryRepository(),
                emotionAnalysisService: MockEmotionAnalysisService()
            ))
        }
    }
}

private actor MockDiaryRepository: DiaryRepository {
    func getDiaries() async throws -> [Diary] {
        return [
            Diary(title: "행복한 점심", content: "오늘은 정말 행복한 하루였다. 친구들과 맛있는 점심을 먹고 즐거운 시간을 보냈다.", emotion: "행복"),
            Diary(title: "우울한 날씨", content: "조금 우울한 기분이다. 날씨도 흐리고 피곤하다.", emotion: "슬픔"),
            Diary(title: "프로젝트 완성!", content: "매우 신나는 일이 있었다! 드디어 프로젝트가 완성되었다!", emotion: "기쁨")
        ]
    }
    
    func saveDiary(_ diary: Diary) async throws {}
    func updateDiary(_ diary: Diary) async throws {}
    func deleteDiary(_ diary: Diary) async throws {}
}

private actor MockEmotionAnalysisService: EmotionAnalysisService {
    func analyzeEmotion(from text: String) async throws -> String {
        return "행복"
    }
}
