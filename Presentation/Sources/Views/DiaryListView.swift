import SwiftUI
import Infrastructure
import Domain

public struct DiaryListView: View {
    @StateObject private var viewModel: DiaryListViewModel
    @State private var showingDiaryEditor = false
    @State private var selectedDiary: Diary?
    @State private var showingDeleteAlert = false
    @State private var diaryToDelete: Diary?
    
    public init(viewModel: DiaryListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ZStack {
            mainContent
            floatingActionButton
        }
        .navigationTitle("일기")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingDiaryEditor) {
            createDiaryEditor()
        }
        .sheet(item: $selectedDiary) { diary in
            editDiaryEditor(diary: diary)
        }
        .alert("일기 삭제", isPresented: $showingDeleteAlert, presenting: diaryToDelete) { diary in
            Button("삭제", role: .destructive) {
                Task {
                    await viewModel.deleteDiary(diary)
                }
            }
            Button("취소", role: .cancel) {}
        } message: { diary in
            Text("이 일기를 삭제하시겠습니까?")
        }
        .task {
            await viewModel.loadDiaries()
        }
    }
    
    private var mainContent: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.diaries.isEmpty {
                emptyStateView
            } else {
                diaryListView
            }
        }
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("아직 일기가 없어요", systemImage: "book.closed")
        } description: {
            Text("오늘의 감정을 기록해볼까요?")
                .foregroundStyle(.secondary)
        } actions: {
            Button {
                showingDiaryEditor = true
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title)
                    .foregroundStyle(.pink)
            }
        }
    }
    
    private var diaryListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.diaries) { diary in
                    DiaryCell(diary: diary)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedDiary = diary
                        }
                }
            }
            .padding(.horizontal)
            .padding(.top)
            .padding(.bottom, 100)
        }
        .scrollIndicators(.hidden)
        .refreshable {
            await viewModel.loadDiaries()
        }
    }
    
    private var floatingActionButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    showingDiaryEditor = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(.pink)
                        .background(Color.white.clipShape(Circle()))
                        .shadow(radius: 4)
                }
                .padding([.trailing, .bottom], 24)
            }
        }
    }
    
    private func createDiaryEditor() -> some View {
        NavigationStack {
            DiaryEditorView(
                viewModel: DiaryEditorViewModel(
                    onSave: { title, content, date in
                        Task {
                            await viewModel.addDiary(title: title, content: content, date: date)
                        }
                    },
                    onDatePickerToggle: { _ in }
                )
            )
        }
    }
    
    private func editDiaryEditor(diary: Diary) -> some View {
        NavigationStack {
            DiaryEditorView(
                viewModel: DiaryEditorViewModel(
                    title: diary.title,
                    content: diary.content,
                    date: diary.date,
                    onSave: { title, content, date in
                        Task {
                            await viewModel.updateDiary(
                                diary,
                                title: title,
                                content: content,
                                date: date
                            )
                        }
                    },
                    onDatePickerToggle: { _ in }
                )
            )
        }
    }
}

private struct DiaryCell: View {
    let diary: Diary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label {
                    Text(diary.title)
                        .font(.headline)
                } icon: {
                    Image(systemName: "pencil.line")
                        .foregroundStyle(.pink)
                }
                Spacer()
                Text(diary.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            if !diary.summary.isEmpty {
                Text(diary.summary)
                    .font(.body)
                    .lineLimit(2)
                    .foregroundStyle(.secondary)
            } else {
                Text(diary.content)
                    .font(.body)
                    .lineLimit(2)
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                EmotionBadge(emotion: diary.emotion)
                    .scaleEffect(0.9)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding()
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

struct DiaryListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DiaryListView(
                viewModel: DiaryListViewModel(
                    repository: MockDiaryRepository(),
                    emotionAnalysisService: MockEmotionAnalysisService(),
                    contentSummaryService: MockContentSummaryService()
                )
            )
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

private actor MockContentSummaryService: ContentSummaryService {
    func summarize(_ content: String) async throws -> String {
        return "요약"
    }
}
