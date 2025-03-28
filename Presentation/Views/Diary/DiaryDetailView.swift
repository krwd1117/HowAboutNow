import SwiftUI
import Domain

public struct DiaryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    let viewModel: DiaryViewModel
    @State var diary: Diary
    @State private var showDeleteConfirmation = false
    
    public init(
        viewModel: DiaryViewModel,
        diary: Diary
    ) {
        self.viewModel = viewModel
        self.diary = diary
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 날짜와 감정 섹션
                dateEmotionSection
                
                // 제목과 내용 섹션
                contentSection
                
                // AI 분석 섹션
                if !diary.summary.isEmpty {
                    analysisSection
                }
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(LocalizedStringKey("diary_detail"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    NavigationLink(
                        destination: {
                            let editorViewModel = DiaryEditorViewModel(
                                diaryViewModel: viewModel,
                                diary: diary,
                                isEditing: true
                            )
                            DiaryEditorView(viewModel: editorViewModel)
                        },
                        label: {
                            Label(LocalizedStringKey("edit"), systemImage: "pencil")
                        }
                    )
                    
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
        .alert(LocalizedStringKey("delete_diary_confirm"), isPresented: $showDeleteConfirmation) {
            Button(LocalizedStringKey("cancel"), role: .cancel) { }
            Button(LocalizedStringKey("delete"), role: .destructive, action: {
                Task {
                    await viewModel.deleteDiary(diary)
                    dismiss()
                }  
            })
        } message: {
            Text(LocalizedStringKey("delete_diary_message"))
        }
    }
    
    // MARK: - Sections
    
    private var dateEmotionSection: some View {
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
    
    private var contentSection: some View {
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
    
    private var analysisSection: some View {
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
