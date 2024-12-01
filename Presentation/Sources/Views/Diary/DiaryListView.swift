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
        mainContent
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
                DiaryListViewComponent(viewModel: viewModel, selectedDiary: $selectedDiary, diaryToDelete: $diaryToDelete, showingDeleteAlert: $showingDeleteAlert)
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
                Text("일기 작성하기")
            }
            .buttonStyle(.bordered)
        }
    }
    
    private func createDiaryEditor() -> some View {
        NavigationStack {
            DiaryEditorView(
                viewModel: DiaryEditorViewModel(
                    onSave: { title, content, date in
                        Task {
                            await viewModel.saveDiary(title: title, content: content, date: date)
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

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct DiaryListViewComponent: View {
    @ObservedObject var viewModel: DiaryListViewModel
    @Binding var selectedDiary: Diary?
    @Binding var diaryToDelete: Diary?
    @Binding var showingDeleteAlert: Bool
    
    var body: some View {
        List {
            ForEach(viewModel.diaries) { diary in
                DiaryCell(diary: diary)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedDiary = diary
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            diaryToDelete = diary
                            showingDeleteAlert = true
                        } label: {
                            Label("삭제", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.loadDiaries()
        }
    }
}

private struct DiaryCell: View {
    let diary: Diary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(diary.title)
                    .font(.headline)
                
                Spacer()
                
                Text(diary.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Text(diary.content)
                .font(.subheadline)
                .lineLimit(2)
                .foregroundStyle(.secondary)
            
            HStack {
                EmotionIcon(emotion: diary.emotion)
                    .font(.caption)
                    .foregroundStyle(.pink)
                
                Spacer()
                
                Text(diary.summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct DiaryListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DiaryListView(
                viewModel: DiaryListViewModel(
                    repository: MockDiaryRepository(),
                    diaryAnalysisService: MockDiaryAnalysisService()
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

private actor MockDiaryAnalysisService: DiaryAnalysisService {
    func analyzeDiary(content: String) async throws -> DiaryAnalysis {
        DiaryAnalysis(emotion: "", summary: "")
    }
    
}
