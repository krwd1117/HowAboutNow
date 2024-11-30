import SwiftUI
import Core

public struct DiaryListView: View {
    @State private var viewModel: DiaryListViewModel
    @State private var isShowingNewDiary = false
    @State private var isShowingEditDiary = false
    @State private var editingContent = ""
    @State private var selectedDiary: Diary?
    
    public init(viewModel: DiaryListViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        List {
            ForEach(viewModel.diaries) { diary in
                DiaryRowView(diary: diary)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedDiary = diary
                        editingContent = diary.content
                        isShowingEditDiary = true
                    }
            }
            .onDelete { indexSet in
                Task {
                    await viewModel.deleteDiaries(at: indexSet)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { 
                    editingContent = ""
                    isShowingNewDiary = true 
                }) {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
        .sheet(isPresented: $isShowingNewDiary) {
            NavigationStack {
                DiaryEditorView(
                    mode: .new,
                    content: $editingContent,
                    onSave: { content in
                        Task {
                            await viewModel.addDiary(content: content)
                            editingContent = ""
                            isShowingNewDiary = false
                        }
                    }
                )
            }
        }
        .sheet(isPresented: $isShowingEditDiary) {
            NavigationStack {
                DiaryEditorView(
                    mode: .edit(content: selectedDiary?.content ?? ""),
                    content: $editingContent,
                    onSave: { content in
                        Task {
                            if let diary = selectedDiary {
                                await viewModel.updateDiary(diary, content: content)
                                editingContent = ""
                                selectedDiary = nil
                                isShowingEditDiary = false
                            }
                        }
                    }
                )
            }
        }
        .task {
            await viewModel.fetchDiaries()
        }
    }
}

private struct DiaryRowView: View {
    let diary: Diary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(diary.content)
                .font(.body)
                .lineLimit(3)
            
            HStack {
                Text(diary.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                if !diary.emotion.isEmpty {
                    Text(diary.emotion)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

private struct DiaryEditorView: View {
    enum Mode {
        case new
        case edit(content: String)
        
        var title: String {
            switch self {
            case .new:
                return "새로운 일기"
            case .edit:
                return "일기 수정"
            }
        }
    }
    
    let mode: Mode
    @Binding var content: String
    let onSave: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            TextField("오늘 하루는 어땠나요?", text: $content, axis: .vertical)
                .lineLimit(5...10)
        }
        .navigationTitle(mode.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("취소") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("저장") {
                    onSave(content)
                }
                .disabled(content.isEmpty)
            }
        }
    }
}
