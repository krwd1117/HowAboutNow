import SwiftUI
import Domain

public struct DiaryView: View {
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
            VStack(spacing: 0) {
                // Custom Navigation Bar
                HStack {
                    Text("일기")
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
                
                // Content
                if viewModel.isCalendarView {
                    DiaryCalendarView(viewModel: viewModel)
                } else {
                    DiaryListView(viewModel: viewModel)
                }
            }
            
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
        .sheet(isPresented: $showingDiaryEditor) {
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
        .sheet(item: $selectedDiary) { diary in
            DiaryEditorView(
                viewModel: DiaryEditorViewModel(
                    title: diary.title,
                    content: diary.content,
                    date: diary.date,
                    onSave: { title, content, date in
                        Task {
                            await viewModel.updateDiary(diary, title: title, content: content, date: date)
                        }
                    },
                    onDatePickerToggle: { _ in }
                )
            )
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
}
