import SwiftUI
import Domain

/// 다이어리 목록 화면
public struct DiaryView: View {
    @StateObject private var viewModel: DiaryListViewModel
    @State private var showingDiaryEditor = false
    @State private var selectedDiary: Diary?
    @State private var showingDeleteAlert = false
    @State private var diaryToDelete: Diary?
    
    /// 초기화
    /// - Parameters:
    ///   - viewModel: 다이어리 목록 뷰 모델
    public init(viewModel: DiaryListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
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
            FloatingAppendButton(showingDiaryEditor: $showingDiaryEditor)
            
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
        .alert("delete_diary_action", isPresented: $showingDeleteAlert, presenting: diaryToDelete) { diary in
            Button("delete", role: .destructive) {
                Task {
                    await viewModel.deleteDiary(diary)
                }
            }
            Button("cancel", role: .cancel) {}
        } message: { diary in
            Text("confirm_delete_diary")
        }
        .task {
            await viewModel.loadDiaries()
        }
    }
}

/// Custom Navigation Bar
fileprivate struct CustomNaivgationBar: View {
    @ObservedObject var viewModel: DiaryListViewModel
    
    var body: some View {
        HStack {
            Text(LocalizedStringKey("diary"))
                .font(.title)
                .fontWeight(.bold)
            
            Spacer()
            
            Button {
                viewModel.toggleViewMode()
            } label: {
                Image(systemName: viewModel.isCalendarView ? "list.bullet" : "calendar")
                    .font(.title2)
            }
        }
        .padding()
    }
}

/// Floating Append Button
fileprivate struct FloatingAppendButton: View {
    @Binding var showingDiaryEditor: Bool
    
    var body: some View {
        // Floating Action Button
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
                        .shadow(radius: 4, y: 2)
                }
                .padding()
            }
        }
    }
}
