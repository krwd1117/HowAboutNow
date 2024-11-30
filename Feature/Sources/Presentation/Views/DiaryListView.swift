import SwiftUI
import Core

public struct DiaryListView: View {
    @StateObject private var viewModel: DiaryListViewModel
    @State private var showingAddDiarySheet = false
    @State private var showingEditDiarySheet = false
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
                    ContentUnavailableView("일기가 없습니다", systemImage: "book.closed")
                } else {
                    diaryList
                }
            }
            .navigationTitle("감정 일기")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: EmotionStatisticsView(viewModel: EmotionStatisticsViewModel(repository: viewModel.repository))) {
                        Image(systemName: "chart.pie")
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddDiarySheet = true }) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .sheet(isPresented: $showingAddDiarySheet) {
                DiaryEditorView(content: "") { content in
                    Task {
                        await viewModel.addDiary(content: content)
                    }
                }
            }
            .sheet(item: $selectedDiary) { diary in
                DiaryEditorView(content: diary.content) { content in
                    Task {
                        await viewModel.updateDiary(diary, content: content)
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
        List {
            ForEach(viewModel.diaries) { diary in
                DiaryCell(diary: diary)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedDiary = diary
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            diaryToDelete = diary
                            showingDeleteAlert = true
                        } label: {
                            Label("삭제", systemImage: "trash")
                        }
                    }
            }
        }
    }
}

private struct DiaryCell: View {
    let diary: Diary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(diary.content)
                .lineLimit(3)
            
            HStack {
                Text(diary.emotion)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text(diary.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
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
            Diary(content: "오늘은 정말 행복한 하루였다", emotion: "행복"),
            Diary(content: "조금 우울한 기분이다", emotion: "우울"),
            Diary(content: "매우 신나는 일이 있었다", emotion: "기쁨")
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
