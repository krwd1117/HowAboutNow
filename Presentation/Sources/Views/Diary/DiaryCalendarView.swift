import SwiftUI
import Domain

public struct DiaryCalendarView: View {
    @ObservedObject var viewModel: DiaryViewModel
    @State private var selectedDate = Date()
    @State private var showingDiaryEditor = false
    @State private var selectedDiary: Diary?
    @State private var showingDeleteAlert = false
    @State private var diaryToDelete: Diary?
    
    public var body: some View {
        VStack(spacing: 0) {
            calendarSection
            Divider().padding(.vertical)
            diarySection
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
