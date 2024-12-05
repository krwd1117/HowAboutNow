import SwiftUI
import Domain

public struct DiaryView: View {
    @StateObject private var viewModel: DiaryViewModel
    @State private var selectedDate = Date()
    @State private var showingDiaryEditor = false
    @State private var selectedDiary: Diary?
    @State private var showingDeleteAlert = false
    @State private var diaryToDelete: Diary?
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
                    date: selectedDate
                )
            )
        }
        .sheet(item: $selectedDiary) { diary in
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
            if let diary = diaryToDelete {
                DeleteConfirmationAlert(
                    viewModel: viewModel,
                    diary: diary,
                    isPresented: $showingDeleteAlert,
                    onComplete: { diaryToDelete = nil }
                ).alert
            } else {
                Alert(title: Text(""))
            }
        }
        .task {
            await viewModel.loadDiaries()
        }
    }
    
    // MARK: - Private Views
    
    private var calendarSection: some View {
        CalendarView(
            selectedDate: $selectedDate,
            diaries: viewModel.diaries,
            onDateSelected: { date in
                withAnimation {
                    selectedDate = date
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
                let filteredDiaries = viewModel.diaries.filter { 
                    Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
                }
                
                if filteredDiaries.isEmpty {
                    EmptyStateView(
                        title: "no_diary_for_date",
                        description: "write_diary_for_date",
                        buttonTitle: "write_new_diary"
                    ) {
                        showingDiaryEditor = true
                    }
                } else {
                    diaryList(diaries: filteredDiaries)
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
                            selectedDiary = diary
                        },
                        onDelete: {
                            diaryToDelete = diary
                            showingDeleteAlert = true
                        }
                    )
                }
            }
            .padding()
        }
    }
}
