import SwiftUI
import Domain

public struct DiaryCalendarView: View {
    @StateObject private var viewModel: DiaryListViewModel
    @State private var showingDiaryEditor = false
    @State private var selectedDiary: Diary?
    @State private var selectedDate = Date()
    @State private var showingDeleteAlert = false
    @State private var diaryToDelete: Diary?
    
    public init(viewModel: DiaryListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ZStack {
            mainContent
            floatingActionButton
        }
        .navigationTitle("일기")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingDiaryEditor) {
            createDiaryEditor()
        }
        .sheet(item: $selectedDiary) { diary in
            editDiaryEditor(diary: diary)
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
    
    private var mainContent: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.diaries.isEmpty {
                emptyStateView
            } else {
                calendarView
            }
        }
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("아직 일기가 없어요", systemImage: "book.closed")
        } description: {
            Text("오늘의 감정을 기록해볼까요?")
                .foregroundStyle(.secondary)
        } actions: {
            Button {
                showingDiaryEditor = true
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title)
                    .foregroundStyle(.pink)
            }
        }
    }
    
    private var calendarView: some View {
        ScrollView {
            VStack(spacing: 20) {
                DatePicker(
                    "날짜 선택",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .tint(.pink)
                
                if let diary = viewModel.diaries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) {
                    DiaryCell(diary: diary)
                        .transition(.move(edge: .bottom))
                        .onTapGesture {
                            selectedDiary = diary
                        }
                } else {
                    ContentUnavailableView {
                        Label("일기 없음", systemImage: "square.dashed")
                    } description: {
                        Text("이 날의 일기가 없어요")
                            .foregroundStyle(.secondary)
                    }
                    .transition(.move(edge: .bottom))
                }
            }
            .padding()
            .animation(.spring, value: selectedDate)
        }
        .scrollIndicators(.hidden)
        .refreshable {
            await viewModel.loadDiaries()
        }
    }
    
    private var floatingActionButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    showingDiaryEditor = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(.pink)
                        .background(Color.white.clipShape(Circle()))
                        .shadow(radius: 4)
                }
                .padding([.trailing, .bottom], 24)
            }
        }
    }
    
    private func createDiaryEditor() -> some View {
        NavigationStack {
            DiaryEditorView(
                viewModel: DiaryEditorViewModel(
                    date: selectedDate,
                    onSave: { title, content, date in
                        Task {
                            await viewModel.addDiary(title: title, content: content, date: date)
                        }
                    },
                    onDatePickerToggle: { _ in }
                )
            )
        }
    }
    
    private func editDiaryEditor(diary: Diary) -> some View {
        NavigationStack {
            DiaryEditorView(
                viewModel: DiaryEditorViewModel(
                    title: diary.title,
                    content: diary.content,
                    date: diary.date,
                    onSave: { title, content, date in
                        Task {
                            await viewModel.updateDiary(
                                diary,
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
    }
}

private struct DiaryCell: View {
    let diary: Diary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label {
                    Text(diary.title)
                        .font(.headline)
                } icon: {
                    Image(systemName: "pencil.line")
                        .foregroundStyle(.pink)
                }
                Spacer()
                Text(diary.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            if !diary.summary.isEmpty {
                Text(diary.summary)
                    .font(.body)
                    .lineLimit(2)
                    .foregroundStyle(.secondary)
            } else {
                Text(diary.content)
                    .font(.body)
                    .lineLimit(2)
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                EmotionBadge(emotion: diary.emotion)
                    .scaleEffect(0.9)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.03), radius: 8, y: 4)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(.quaternary, lineWidth: 0.5)
        }
    }
}
