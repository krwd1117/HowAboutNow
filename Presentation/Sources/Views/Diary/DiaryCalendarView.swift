import SwiftUI
import Domain

public struct DiaryCalendarView: View {
    @ObservedObject var viewModel: DiaryViewModel
    @State private var selectedDate = Date()
    @State private var showingDiaryEditor = false
    @State private var selectedDiary: Diary?
    @State private var showingDeleteAlert = false
    @State private var diaryToDelete: Diary?
    @Environment(\.colorScheme) private var colorScheme
    
    public var body: some View {
        VStack(spacing: 0) {
            // 캘린더 뷰
            CalendarView(
                selectedDate: $selectedDate,
                diaries: viewModel.diaries
            ) { _ in }
            .padding(.horizontal)
            
            Divider()
                .padding(.vertical)
            
            // 선택된 날짜의 다이어리 목록
            let selectedDiaries = viewModel.diaries.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
            
            if !selectedDiaries.isEmpty {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(selectedDiaries) { diary in
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
            } else {
                EmptyStateView(
                    title: "no_diary_for_date",
                    description: "write_diary_for_date",
                    buttonTitle: "write_new_diary"
                ) {
                    showingDiaryEditor = true
                }
            }
        }
        .sheet(isPresented: $showingDiaryEditor) {
            DiaryEditorView(
                viewModel: DiaryEditorViewModel(
                    date: selectedDate,
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
    }
}
