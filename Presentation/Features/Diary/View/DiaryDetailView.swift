import SwiftUI
import Domain

public struct DiaryDetailView: View {
    @ObservedObject private var coordinator: DiaryCoordinator
    @StateObject private var viewModel: DiaryDetailViewModel
    @State private var showDeleteConfirmation = false

    init(
        coordinator: DiaryCoordinator,
        diary: Diary,
        showDeleteConfirmation: Bool = false
    ) {
        self.coordinator = coordinator
        self._viewModel = StateObject(wrappedValue: DiaryDetailViewModel(
            diContainer: coordinator.diContainer, diary: diary
        ))
        self.showDeleteConfirmation = showDeleteConfirmation
    }

    public var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                coordinator: coordinator,
                title: "diary_detail",
                showBackButton: true,
                rightButton: {
                    AnyView(
                        NavigationBarMenu(
                            coordinator: coordinator,
                            showDeleteConfirmation: $showDeleteConfirmation,
                            diary: viewModel.diary
                        )
                    )
                }
            )
            ScrollView {
                VStack(spacing: 24) {
                    // 날짜와 감정 섹션
                    DateEmotionSection(diary: viewModel.diary)

                    // 제목과 내용 섹션
                    ContentSection(diary: viewModel.diary)

                    // AI 분석 섹션
                    if !viewModel.diary.summary.isEmpty {
                        AnalysisSection(diary: viewModel.diary)
                    }
                }
                .padding()
            }
            .alert(LocalizedStringKey("delete_diary_confirm"), isPresented: $showDeleteConfirmation) {
                Button(LocalizedStringKey("cancel"), role: .cancel) { }
                Button(LocalizedStringKey("delete"), role: .destructive, action: {
                    Task {
                        await viewModel.deleteDiary()
                        coordinator.navigateBackToList()
                    }
                })
            } message: {
                Text(LocalizedStringKey("delete_diary_message"))
            }
        }
        .navigationBarHidden(true)
        .background(Color(uiColor: .systemGroupedBackground))
        .contentShape(Rectangle()) // 제스처 감지 영역 확장
        .gesture(
            DragGesture(minimumDistance: 20)
                .onEnded { value in
                    // 좌에서 우로 스와이프 판별
                    if value.translation.width > 50 && abs(value.translation.height) < 30 {
                        coordinator.pop() // 뒤로가기 호출
                    }
                }
        )
    }
}

fileprivate struct NavigationBarMenu: View {
    @ObservedObject var coordinator: DiaryCoordinator
    @Binding var showDeleteConfirmation: Bool
    var diary: Diary

    var body: some View {
        Menu {
            Button(action: {
                coordinator.push(route: .editor(.edit, diary))
            }, label: {
                Label(LocalizedStringKey("edit"), systemImage: "pencil")
            })
            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Label(LocalizedStringKey("delete"), systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Sections

fileprivate struct DateEmotionSection: View {
    
    private let diary: Diary
    
    init(diary: Diary) {
        self.diary = diary
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Label {
                Text(diary.date.formatted(date: .abbreviated, time: .omitted))
                    .foregroundStyle(.primary)
            } icon: {
                Image(systemName: "calendar")
                    .foregroundStyle(.pink)
            }
            .font(.subheadline)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
    }
}

fileprivate struct ContentSection: View {
    
    private let diary: Diary
    
    init(diary: Diary) {
        self.diary = diary
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(diary.title)
                    .font(.title)
                    .fontWeight(.bold)

                EmotionIcon(emotion: diary.emotion)
                    .foregroundStyle(.primary)
            }

            Text(diary.content)
                .font(.body)
                .lineSpacing(8)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
    }
}

fileprivate struct AnalysisSection: View {
    
    let diary: Diary
    
    init(diary: Diary) {
        self.diary = diary
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label {
                Text(LocalizedStringKey("ai_analysis"))
                    .font(.headline)
            } icon: {
                Image(systemName: "wand.and.stars")
                    .foregroundStyle(.pink)
                    .symbolEffect(.bounce)
            }
            
            Text(diary.summary)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(8)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
    }
}
