import SwiftUI
import Domain

/// 다이어리 목록 화면
public struct DiaryListView: View {
    @ObservedObject private var viewModel: DiaryViewModel
    @State private var showingDiaryEditor = false
    @State private var selectedDiary: Diary?
    @State private var showingDeleteAlert = false
    @State private var diaryToDelete: Diary?
    @Environment(\.colorScheme) private var colorScheme
    
    /// 초기화
    /// - Parameter viewModel: 다이어리 ViewModel
    public init(viewModel: DiaryViewModel) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ZStack {
            mainContent
            FloatingActionButton(
                action: { showingDiaryEditor = true }
            )
        }
        .navigationTitle("diary_title")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingDiaryEditor) {
            DiaryEditorSheet(
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
    
    /// 메인 컨텐츠
    private var mainContent: some View {
        Group {
            if viewModel.isLoading {
                // 로딩 뷰
                ProgressView()
                    .scaleEffect(1.2)
            } else if viewModel.diaries.isEmpty {
                // 빈 상태 뷰
                EmptyStateView(
                    title: "empty_diary_title",
                    description: "empty_diary_description",
                    buttonTitle: "write_new_diary"
                ) {
                    showingDiaryEditor = true
                }
            } else {
                diaryList
            }
        }
    }
    
    /// 다이어리 목록
    private var diaryList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.diaries) { diary in
                    DiaryCardView(
                        diary: diary,
                        onTap: { selectedDiary = diary },
                        onDelete: {
                            diaryToDelete = diary
                            showingDeleteAlert = true
                        }
                    )
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
}

/// 프리뷰
struct DiaryListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DiaryListView(
                viewModel: DiaryViewModel(
                    repository: MockDiaryRepository(),
                    diaryAnalysisService: MockDiaryAnalysisService()
                )
            )
        }
    }
}

/// 모의 다이어리 리포지토리
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

/// 모의 다이어리 분석 서비스
private actor MockDiaryAnalysisService: DiaryAnalysisService {
    func analyzeDiary(content: String) async throws -> DiaryAnalysis {
        DiaryAnalysis(emotion: "", summary: "")
    }
}
