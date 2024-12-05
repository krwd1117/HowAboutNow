import SwiftUI
import Domain

/// 다이어리 카드 뷰
public struct DiaryCardView: View {
    let diary: Diary
    let onTap: () -> Void
    let onDelete: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    public init(
        diary: Diary,
        onTap: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.diary = diary
        self.onTap = onTap
        self.onDelete = onDelete
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 제목과 날짜
            HStack {
                Text(diary.title)
                    .font(.headline)
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
            
            // 감정 태그
            HStack {
                Text(diary.emotion)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.2))
                    .cornerRadius(8)
                
                Spacer()
                
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
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(white: 0.15) : .white)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .onTapGesture(perform: onTap)
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("삭제", systemImage: "trash")
            }
        }
    }
}
