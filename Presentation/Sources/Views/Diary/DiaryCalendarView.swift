import SwiftUI
import Domain

public struct DiaryCalendarView: View {
    @ObservedObject var viewModel: DiaryListViewModel
    @State private var selectedDate = Date()
    @State private var showingDiaryEditor = false
    @State private var selectedDiary: Diary?
    
    public var body: some View {
        VStack(spacing: 0) {
            CalendarView(
                selectedDate: $selectedDate,
                diaries: viewModel.diaries) { _ in
                    
                }
            .padding(.horizontal)
            
            Divider()
                .padding(.vertical)
            
            let selectedDiaries = viewModel.diaries.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
            
            if !selectedDiaries.isEmpty {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(selectedDiaries) { diary in
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text(diary.title)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                    
                                    Spacer()
                                    
                                    Menu {
                                        Button {
                                            selectedDiary = diary
                                        } label: {
                                            Label("수정", systemImage: "pencil")
                                        }
                                        
                                        Button(role: .destructive) {
                                            // TODO: Delete diary
                                        } label: {
                                            Label("삭제", systemImage: "trash")
                                        }
                                    } label: {
                                        Image(systemName: "ellipsis")
                                            .fontWeight(.bold)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                
                                Text(diary.content)
                                    .font(.body)
                                
                                HStack {
                                    EmotionIcon(emotion: diary.emotion)
                                        .font(.footnote)
                                        .foregroundStyle(.pink)
                                    
                                    Spacer()
                                    
                                    if !diary.summary.isEmpty {
                                        Text(diary.summary)
                                            .font(.footnote)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            } else {
                VStack(spacing: 16) {
                    Text("이 날의 일기가 없습니다")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    Button {
                        showingDiaryEditor = true
                    } label: {
                        Text("일기 작성하기")
                    }
                    .buttonStyle(.bordered)
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
            DiaryEditorView(viewModel: DiaryEditorViewModel(
                title: diary.title,
                content: diary.content,
                date: diary.date,
                onSave: { title, content, date in
                    Task {
                        await viewModel.updateDiary(diary, title: title, content: content, date: date)
                    }
                },
                onDatePickerToggle: { _ in }
            ))
        }
    }
}
