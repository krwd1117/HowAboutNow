import SwiftUI
import Core

public struct DiaryListView: View {
    @State private var viewModel: DiaryListViewModel
    @State private var isShowingNewDiary = false
    @State private var isShowingEditDiary = false
    @State private var selectedDiary: Diary?
    @State private var editingContent = ""
    
    public init(viewModel: DiaryListViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }
    
    public var body: some View {
        List {
            ForEach(viewModel.diaries) { diary in
                DiaryRowView(diary: diary)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            Task {
                                await viewModel.deleteDiary(diary)
                            }
                        } label: {
                            Label("삭제", systemImage: "trash")
                        }
                    }
                    .onTapGesture {
                        selectedDiary = diary
                        editingContent = diary.content
                        isShowingEditDiary = true
                    }
            }
        }
        .navigationTitle("일기")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    NavigationLink {
                        EmotionStatisticsView(viewModel: EmotionStatisticsViewModel(repository: viewModel.repository))
                    } label: {
                        Image(systemName: "chart.pie")
                    }
                    
                    Button {
                        editingContent = ""
                        isShowingNewDiary = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingNewDiary) {
            NavigationStack {
                DiaryEditorView(
                    mode: .new,
                    content: editingContent
                ) { content in
                    Task {
                        await viewModel.addDiary(content: content)
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingEditDiary) {
            if let diary = selectedDiary {
                NavigationStack {
                    DiaryEditorView(
                        mode: .edit(diary),
                        content: editingContent
                    ) { content in
                        Task {
                            await viewModel.updateDiary(diary, content: content)
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.fetchDiaries()
        }
    }
}

struct DiaryRowView: View {
    let diary: Diary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(diary.content)
                .lineLimit(2)
            
            HStack {
                Text(diary.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text(diary.emotion)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 4)
    }
}

struct DiaryEditorView: View {
    enum Mode {
        case new
        case edit(Diary)
        
        var title: String {
            switch self {
            case .new: return "새 일기"
            case .edit: return "일기 수정"
            }
        }
    }
    
    let mode: Mode
    let content: String
    let onSave: (String) -> Void
    
    @State private var editedContent: String
    @Environment(\.dismiss) private var dismiss
    
    init(mode: Mode, content: String, onSave: @escaping (String) -> Void) {
        self.mode = mode
        self.content = content
        self.onSave = onSave
        self._editedContent = State(initialValue: content)
    }
    
    var body: some View {
        Form {
            TextField("오늘 하루는 어땠나요?", text: $editedContent, axis: .vertical)
                .lineLimit(5...10)
        }
        .navigationTitle(mode.title)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("취소") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("저장") {
                    onSave(editedContent)
                    dismiss()
                }
                .disabled(editedContent.isEmpty)
            }
        }
    }
}
