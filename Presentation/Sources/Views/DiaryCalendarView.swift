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
            if viewModel.isCalendarView {
                calendarContent
            } else {
                listContent
            }
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation {
                        viewModel.toggleViewMode()
                    }
                } label: {
                    Image(systemName: viewModel.isCalendarView ? "list.bullet" : "calendar")
                }
                .foregroundStyle(.pink)
            }
        }
    }
    
    private var calendarContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                CalendarView(
                    selectedDate: $selectedDate,
                    diaries: viewModel.diaries
                ) { date in
                    selectedDate = date
                }
                .padding(.horizontal)
                
                let selectedDiaries = viewModel.diaries.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
                
                if !selectedDiaries.isEmpty {
                    LazyVStack(spacing: 16) {
                        ForEach(selectedDiaries) { diary in
                            DiaryCell(diary: diary)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                                .onTapGesture {
                                    selectedDiary = diary
                                }
                        }
                    }
                } else {
                    ContentUnavailableView {
                        Label("일기 없음", systemImage: "square.dashed")
                    } description: {
                        Text("이 날의 일기가 없어요")
                            .foregroundStyle(.secondary)
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding()
            .animation(.snappy(duration: 0.25), value: selectedDate)
        }
        .scrollIndicators(.hidden)
        .refreshable {
            await viewModel.loadDiaries()
        }
    }
    
    private var listContent: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.diaries) { diary in
                    DiaryCell(diary: diary)
                        .onTapGesture {
                            selectedDiary = diary
                        }
                }
            }
            .padding()
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
