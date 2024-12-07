import SwiftUI
import Domain

public struct DiaryDetailView: View {
    let diary: Diary
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirmation = false
    
    public init(
        diary: Diary,
        onEdit: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.diary = diary
        self.onEdit = onEdit
        self.onDelete = onDelete
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
        .navigationTitle(diary.title)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: onEdit) {
                        Label("edit", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .alert("delete_diary_confirm", isPresented: $showDeleteConfirmation) {
            Button("cancel", role: .cancel) { }
            Button("delete", role: .destructive, action: onDelete)
        } message: {
            Text("delete_diary_message")
        }
    }
    
    // MARK: - Sections
    
    private var dateEmotionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                Text(diary.date.formatted(date: .abbreviated, time: .omitted))
                    .foregroundStyle(.primary)
            } icon: {
                Image(systemName: "calendar")
                    .foregroundStyle(.pink)
            }
            .font(.subheadline)
            
            Label {
                Text(LocalizedStringKey(diary.emotion))
                    .foregroundStyle(.primary)
            } icon: {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.pink)
                    .symbolEffect(.bounce)
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
            Text(diary.title)
                .font(.title)
                .fontWeight(.bold)
            
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
                Text("ai_analysis")
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
