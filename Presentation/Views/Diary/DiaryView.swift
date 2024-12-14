import SwiftUI
import Domain

public struct DiaryView: View {
    @ObservedObject private var viewModel: DiaryViewModel
    @State private var showingListView = false
    
    public init(viewModel: DiaryViewModel) {
        self.viewModel = viewModel
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
                        showingListView: showingListView
                    )
                }
                
                FloatingActionButton(
                    destination: DiaryEditorView(
                        viewModel: DiaryEditorViewModel(
                            diaryViewModel: viewModel,
                            diary: nil,
                            title: "",
                            content: "",
                            date: viewModel.selectedDate,
                            emotion: "",
                            isEditing: false
                        )
                    )
                )
            }
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
            .task {
                await viewModel.loadDiaries()
            }
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
    
    var body: some View {
        Group {
            let diariesToShow = showingListView ? viewModel.diaries : viewModel.filteredDiaries
            let emptyTitle = showingListView ? LocalizedStringKey("empty_diary") : LocalizedStringKey("empty_diary_for_date")
            let emptyDescription = showingListView ? LocalizedStringKey("write_first_diary") : LocalizedStringKey("write_diary_for_date")
            
            if diariesToShow.isEmpty {
                EmptyStateView(
                    viewModel: viewModel,
                    title: emptyTitle,
                    description: emptyDescription,
                    buttonTitle: LocalizedStringKey("write_new_diary")
                ) {}
            } else {
                DiaryListView(
                    diaries: diariesToShow,
                    viewModel: viewModel
                )
            }
        }
    }
}

fileprivate struct DiaryListView: View {
    let diaries: [Diary]
    @ObservedObject var viewModel: DiaryViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(diaries) { diary in
                    DiaryCardView(
                        viewModel: viewModel,
                        diary: diary
                    )
                }
            }
            .padding()
        }
    }
}
