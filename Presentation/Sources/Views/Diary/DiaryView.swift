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
    
    init(viewModel: DiaryViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
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
            DiaryEditorSheet(
                date: selectedDate,
                onSave: { title, content, date, emotion in
                    Task {
                        await viewModel.saveDiary(
                            title: title,
                            content: content,
                            date: date
                        )
                    }
                }
            )
        }
        .sheet(item: $selectedDiary) { diary in
            DiaryEditorSheet(
                diary: diary,
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
                }
            )
        }
        .alert(isPresented: $showingDeleteAlert) {
            DeleteConfirmationAlert(
                isPresented: $showingDeleteAlert,
                onDelete: {
                    if let diary = diaryToDelete {
                        Task {
                            await viewModel.deleteDiary(diary)
                        }
                    }
                    diaryToDelete = nil
                }
            ).alert
        }
        .task {
            await viewModel.loadDiaries()
        }
    }
    
    // MARK: - Private Views
    
    private var calendarSection: some View {
        CalendarView(
            selectedDate: $selectedDate,
            diaries: viewModel.diaries
        ) { _ in }
        .padding(.horizontal)
    }
    
    private var diarySection: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if showingListView {
                listContent
            } else {
                dateFilteredContent
            }
        }
    }
    
    private var dateFilteredContent: some View {
        let selectedDiaries = viewModel.diaries.filter { 
            Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
        }
        
        return Group {
            if selectedDiaries.isEmpty {
                EmptyStateView(
                    title: "no_diary_for_date",
                    description: "write_diary_for_date",
                    buttonTitle: "write_new_diary"
                ) {
                    showingDiaryEditor = true
                }
            } else {
                diaryList(diaries: selectedDiaries)
            }
        }
    }
    
    private var listContent: some View {
        Group {
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
        }
    }
    
    private func diaryList(diaries: [Diary]) -> some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(diaries) { diary in
                    DiaryCardView(
                        diary: diary,
                        onTap: { selectedDiary = diary },
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
