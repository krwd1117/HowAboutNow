import SwiftUI
import Domain

public struct DiaryCalendarView: View {
    @ObservedObject var viewModel: DiaryListViewModel
    @State private var selectedDate = Date()
    @State private var showingDiaryEditor = false
    @State private var selectedDiary: Diary?
    @Environment(\.colorScheme) private var colorScheme
    
    public var body: some View {
        VStack(spacing: 0) {
            CalendarView(
                selectedDate: $selectedDate,
                diaries: viewModel.diaries
            ) { _ in }
            .padding(.horizontal)
            
            Divider()
                .padding(.vertical)
            
            let selectedDiaries = viewModel.diaries.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
            
            if !selectedDiaries.isEmpty {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(selectedDiaries) { diary in
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(alignment: .center, spacing: 8) {
                                    EmotionIcon(emotion: diary.emotion)
                                        .font(.title2)
                                        .symbolEffect(.bounce)
                                    
                                    Text(diary.title)
                                        .font(.headline)
                                    
                                    Spacer()
                                    
                                    Menu {
                                        Button {
                                            selectedDiary = diary
                                        } label: {
                                            Label("edit", systemImage: "pencil")
                                        }
                                        
                                        Button(role: .destructive) {
                                            // TODO: Delete diary
                                        } label: {
                                            Label("delete", systemImage: "trash")
                                        }
                                    } label: {
                                        Image(systemName: "ellipsis.circle.fill")
                                            .font(.title3)
                                            .symbolRenderingMode(.hierarchical)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                
                                Text(diary.content)
                                    .font(.body)
                                    .lineLimit(3)
                                
                                if !diary.summary.isEmpty {
                                    HStack(spacing: 4) {
                                        Image(systemName: "quote.opening")
                                            .font(.caption2)
                                            .foregroundStyle(.pink)
                                        
                                        Text(diary.summary)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                        
                                        Image(systemName: "quote.closing")
                                            .font(.caption2)
                                            .foregroundStyle(.pink)
                                    }
                                    .padding(.top, 4)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(colorScheme == .dark ? Color(uiColor: .secondarySystemBackground) : .white)
                                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color.pink.opacity(0.1), lineWidth: 1)
                            )
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            } else {
                ContentUnavailableView {
                    Label {
                        Text("no_diary_for_date")
                    } icon: {
                        Image(systemName: "book.closed")
                            .symbolEffect(.bounce)
                            .foregroundStyle(.pink)
                            .font(.largeTitle)
                    }
                } description: {
                    Text("write_diary_for_date")
                        .foregroundStyle(.secondary)
                } actions: {
                    Button {
                        showingDiaryEditor = true
                    } label: {
                        Label("write_new_diary", systemImage: "plus")
                            .font(.body.weight(.medium))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.pink)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .sheet(isPresented: $showingDiaryEditor) {
            DiaryEditorView(
                viewModel: DiaryEditorViewModel(
                    date: selectedDate,
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
    }
}
