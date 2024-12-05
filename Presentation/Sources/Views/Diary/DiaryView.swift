import SwiftUI
import Domain

public struct DiaryView: View {
    @StateObject private var viewModel: DiaryViewModel
    @State private var showingDiaryEditor = false
    @State private var showingDeleteAlert = false
    @State private var showingListView = false
    
    public init(
        diaryRepository: any DiaryRepository,
        diaryAnalysisService: any DiaryAnalysisService
    ) {
        _viewModel = StateObject(
            wrappedValue: DiaryViewModel(
                diaryRepository: diaryRepository,
                diaryAnalysisService: diaryAnalysisService
            )
        )
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    if !showingListView {
                        calendarSection
                        Divider().padding(.vertical)
                    }
                    
                    diarySection
                }
                
                FloatingActionButton(
                    action: { showingDiaryEditor = true }
                )
            }
            .navigationTitle("diary_title")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation {
                            showingListView.toggle()
                        }
                    } label: {
                        Image(systemName: showingListView ? "calendar" : "list.bullet")
                    }
                }
            }
        }
        .sheet(isPresented: $showingDiaryEditor) {
            DiaryEditorView(
                viewModel: DiaryEditorViewModel(
                    diaryViewModel: viewModel,
                    date: viewModel.selectedDate
                )
            )
        }
        .sheet(item: $viewModel.selectedDiary) { diary in
            DiaryEditorView(
                viewModel: DiaryEditorViewModel(
                    diaryViewModel: viewModel,
                    diary: diary,
                    title: diary.title,
                    content: diary.content,
                    date: diary.date,
                    emotion: diary.emotion,
                    isEditing: true
                )
            )
        }
        .alert(isPresented: $showingDeleteAlert) {
            if let diary = viewModel.diaryToDelete {
                DeleteConfirmationAlert(
                    viewModel: viewModel,
                    diary: diary,
                    isPresented: $showingDeleteAlert,
                    onComplete: { viewModel.markForDeletion(nil) }
                ).alert
            } else {
                Alert(title: Text(""))
            }
        }
        .task {
            await viewModel.loadDiaries()
        }
    }
    
    private var calendarSection: some View {
        CalendarView(
            selectedDate: $viewModel.selectedDate,
            diaries: viewModel.diaries,
            onDateSelected: { date in
                withAnimation {
                    viewModel.selectedDate = date
                }
            }
        )
        .padding(.horizontal)
    }
    
    private var diarySection: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if showingListView {
                if viewModel.diaries.isEmpty {
                    EmptyStateView(
                        title: "no_diary",
                        description: "write_first_diary",
                        buttonTitle: "write_new_diary"
                    ) {
                        showingDiaryEditor = true
                    }
                } else {
                    diaryList(diaries: viewModel.diaries)
                }
            } else {
                if viewModel.filteredDiaries.isEmpty {
                    EmptyStateView(
                        title: "no_diary_for_date",
                        description: "write_diary_for_date",
                        buttonTitle: "write_new_diary"
                    ) {
                        showingDiaryEditor = true
                    }
                } else {
                    diaryList(diaries: viewModel.filteredDiaries)
                }
            }
        }
    }
    
    private func diaryList(diaries: [Diary]) -> some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(diaries) { diary in
                    DiaryCardView(
                        diary: diary,
                        onTap: {
                            viewModel.selectDiary(diary)
                        },
                        onDelete: {
                            viewModel.markForDeletion(diary)
                            showingDeleteAlert = true
                        }
                    )
                }
            }
            .padding()
        }
    }
}
