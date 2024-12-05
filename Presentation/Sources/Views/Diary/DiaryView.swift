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
                        DiaryCalendarSection(viewModel: viewModel)
                        Divider().padding(.vertical)
                    }
                    
                    DiaryContentSection(
                        viewModel: viewModel,
                        showingListView: showingListView,
                        showingDiaryEditor: $showingDiaryEditor,
                        showingDeleteAlert: $showingDeleteAlert
                    )
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
}

// MARK: - Subviews

fileprivate struct DiaryCalendarSection: View {
    @ObservedObject var viewModel: DiaryViewModel
    
    var body: some View {
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
}

fileprivate struct DiaryContentSection: View {
    @ObservedObject var viewModel: DiaryViewModel
    let showingListView: Bool
    @Binding var showingDiaryEditor: Bool
    @Binding var showingDeleteAlert: Bool
    
    var body: some View {
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
                    DiaryListView(
                        diaries: viewModel.diaries,
                        viewModel: viewModel,
                        showingDeleteAlert: $showingDeleteAlert
                    )
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
                    DiaryListView(
                        diaries: viewModel.filteredDiaries,
                        viewModel: viewModel,
                        showingDeleteAlert: $showingDeleteAlert
                    )
                }
            }
        }
    }
}

fileprivate struct DiaryListView: View {
    let diaries: [Diary]
    @ObservedObject var viewModel: DiaryViewModel
    @Binding var showingDeleteAlert: Bool
    
    var body: some View {
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
