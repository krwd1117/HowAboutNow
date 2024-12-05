import SwiftUI
import Domain

/// 다이어리 목록 화면
public struct DiaryView: View {
    @ObservedObject private var viewModel: DiaryViewModel
    @State private var showingDiaryEditor = false
    @State private var selectedDiary: Diary?
    @State private var showingDeleteAlert = false
    @State private var diaryToDelete: Diary?
    
    /// 초기화
    /// - Parameters:
    ///   - viewModel: 다이어리 뷰 모델
    public init(viewModel: DiaryViewModel) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Custom Navigation Bar
                CustomNaivgationBar(viewModel: viewModel)
                
                // Content
                if viewModel.isCalendarView {
                    DiaryCalendarView(viewModel: viewModel)
                } else {
                    DiaryListView(viewModel: viewModel)
                }
            }
            
            // Floating Action Button
            FloatingAppendButton(viewModel: viewModel, showingDiaryEditor: $showingDiaryEditor)
        }
        .sheet(isPresented: $showingDiaryEditor) {
            DiaryEditorView(
                viewModel: DiaryEditorViewModel(
                    onSave: { title, content, date, emotion in
                        Task {
                            await viewModel.saveDiary(
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
        .sheet(item: $selectedDiary) { diary in
            DiaryEditorView(
                viewModel: DiaryEditorViewModel(
                    title: diary.title,
                    content: diary.content,
                    date: diary.date,
                    emotion: diary.emotion,
                    isEditing: true,
                    onSave: { title, content, date, emotion in
                        Task {
                            await viewModel.updateDiary(
                                diary,
                                title: title,
                                content: content,
                                date: date,
                                emotion: emotion
                            )
                        }
                    },
                    onDatePickerToggle: { _ in }
                )
            )
        }
        .alert("일기를 삭제하시겠습니까?", isPresented: $showingDeleteAlert) {
            Button("삭제", role: .destructive) {
                if let diary = diaryToDelete {
                    Task {
                        await viewModel.deleteDiary(diary)
                    }
                }
                diaryToDelete = nil
            }
            Button("취소", role: .cancel) {
                diaryToDelete = nil
            }
        }
        .task {
            await viewModel.loadDiaries()
        }
    }
}

// MARK: - Custom Navigation Bar
private struct CustomNaivgationBar: View {
    @ObservedObject var viewModel: DiaryViewModel
    
    var body: some View {
        HStack {
            Text("일기")
                .font(.title)
                .bold()
            
            Spacer()
            
            Button {
                viewModel.toggleViewMode()
            } label: {
                Image(systemName: viewModel.isCalendarView ? "list.bullet" : "calendar")
                    .font(.title2)
            }
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
    }
}

// MARK: - Floating Action Button
private struct FloatingAppendButton: View {
    @ObservedObject var viewModel: DiaryViewModel
    @Binding var showingDiaryEditor: Bool
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    showingDiaryEditor = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.accentColor)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                .padding()
            }
        }
    }
}
