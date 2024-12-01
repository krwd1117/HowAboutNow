import SwiftUI
import Domain

public struct DiaryListView: View {
    @StateObject private var viewModel: DiaryListViewModel
    @State private var showingDiaryEditor = false
    @State private var selectedDiary: Diary?
    @State private var showingDeleteAlert = false
    @State private var diaryToDelete: Diary?
    @Environment(\.colorScheme) private var colorScheme
    
    public init(viewModel: DiaryListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ZStack {
            backgroundGradient
            mainContent
            floatingActionButton
            #if DEBUG
            debugCrashButton
            #endif
        }
        .navigationTitle("diary_title")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingDiaryEditor) {
            createDiaryEditor()
        }
        .sheet(item: $selectedDiary) { diary in
            editDiaryEditor(diary: diary)
        }
        .alert("delete_diary", isPresented: $showingDeleteAlert, presenting: diaryToDelete) { diary in
            Button("delete", role: .destructive) {
                Task {
                    await viewModel.deleteDiary(diary)
                }
            }
            Button("cancel", role: .cancel) {}
        } message: { diary in
            Text("delete_diary_confirm")
        }
        .task {
            await viewModel.loadDiaries()
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(uiColor: .systemBackground),
                Color(uiColor: .systemBackground).opacity(0.95),
                Color.pink.opacity(0.1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    private var mainContent: some View {
        Group {
            if viewModel.isLoading {
                loadingView
            } else if viewModel.diaries.isEmpty {
                emptyStateView
            } else {
                DiaryListViewComponent(viewModel: viewModel, selectedDiary: $selectedDiary, diaryToDelete: $diaryToDelete, showingDeleteAlert: $showingDeleteAlert)
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("loading_diaries")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label {
                Text("empty_diary_title")
            } icon: {
                Image(systemName: "book.closed")
                    .symbolEffect(.bounce)
                    .foregroundStyle(.pink)
                    .font(.largeTitle)
            }
        } description: {
            Text("empty_diary_description")
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
    }
    
    private var floatingActionButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        showingDiaryEditor = true
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.pink, .pink.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                        )
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                }
                .padding([.trailing, .bottom], 20)
                .buttonStyle(BounceButtonStyle())
            }
        }
    }
    
    #if DEBUG
    private var debugCrashButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    fatalError("Crash was triggered")
                } label: {
                    Image(systemName: "ladybug.fill")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.red, .red.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                }
                .padding([.trailing, .bottom], 20)
            }
            .padding(.bottom, 70)
        }
    }
    #endif
    
    private func createDiaryEditor() -> some View {
        NavigationStack {
            DiaryEditorView(
                viewModel: DiaryEditorViewModel(
                    onSave: { title, content, date, emotion in
                        Task {
                            await viewModel.saveDiary(title: title, content: content, date: date)
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
    }
}

struct BounceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct DiaryListViewComponent: View {
    @ObservedObject var viewModel: DiaryListViewModel
    @Binding var selectedDiary: Diary?
    @Binding var diaryToDelete: Diary?
    @Binding var showingDeleteAlert: Bool
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.diaries) { diary in
                    DiaryCell(diary: diary)
                        .onTapGesture {
                            selectedDiary = diary
                        }
                        .contextMenu {
                            Button {
                                selectedDiary = diary
                            } label: {
                                Label("수정하기", systemImage: "pencil")
                            }
                            
                            Button(role: .destructive) {
                                diaryToDelete = diary
                                showingDeleteAlert = true
                            } label: {
                                Label("삭제하기", systemImage: "trash")
                            }
                        }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .scrollIndicators(.hidden)
        .refreshable {
            await viewModel.loadDiaries()
        }
    }
}

struct DiaryCell: View {
    let diary: Diary
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 8) {
                EmotionIcon(emotion: diary.emotion)
                    .font(.title2)
                    .symbolEffect(.bounce)
                
                Text(diary.title)
                    .font(.headline)
                    .foregroundStyle(Color.primary)
                
                Spacer()
                
                Text(diary.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Text(diary.content)
                .font(.body)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
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
    }
}

struct DiaryListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DiaryListView(
                viewModel: DiaryListViewModel(
                    repository: MockDiaryRepository(),
                    diaryAnalysisService: MockDiaryAnalysisService()
                )
            )
        }
    }
}

private actor MockDiaryRepository: DiaryRepository {
    func getDiaries() async throws -> [Diary] {
        return [
            Diary(title: "행복한 점심", content: "오늘은 정말 행복한 하루였다. 친구들과 맛있는 점심을 먹고 즐거운 시간을 보냈다.", emotion: "행복"),
            Diary(title: "우울한 날씨", content: "조금 우울한 기분이다. 날씨도 흐리고 피곤하다.", emotion: "슬픔"),
            Diary(title: "프로젝트 완성!", content: "매우 신나는 일이 있었다! 드디어 프로젝트가 완성되었다!", emotion: "기쁨")
        ]
    }
    
    func saveDiary(_ diary: Diary) async throws {}
    func updateDiary(_ diary: Diary) async throws {}
    func deleteDiary(_ diary: Diary) async throws {}
}

private actor MockDiaryAnalysisService: DiaryAnalysisService {
    func analyzeDiary(content: String) async throws -> DiaryAnalysis {
        DiaryAnalysis(emotion: "", summary: "")
    }
}
