import SwiftUI
import Domain

/// 다이어리 카드 뷰
public struct DiaryCardView: View {
    let diary: Diary
    let onTap: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    public init(
        diary: Diary,
        onTap: @escaping () -> Void,
        onEdit: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.diary = diary
        self.onTap = onTap
        self.onEdit = onEdit
        self.onDelete = onDelete
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 제목, 감정, 날짜
            HStack {
                HStack(spacing: 8) {
                    Text(diary.title)
                        .font(.headline)
                    
                    EmotionIcon(emotion: diary.emotion)
                }
                
                Spacer()
                
                Text(diary.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // 내용
            Text(diary.content)
                .font(.subheadline)
                .lineLimit(3)
                .foregroundColor(.secondary)
            
            // AI 분석
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
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(white: 0.15) : .white)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .onTapGesture(perform: onTap)
        .contextMenu {
            Button(action: onEdit) {
                Label("수정", systemImage: "pencil")
            }
            
            Button(role: .destructive, action: onDelete) {
                Label("삭제", systemImage: "trash")
            }
        }
    }
}
