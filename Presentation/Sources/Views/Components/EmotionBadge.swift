import SwiftUI

public struct EmotionBadge: View {
    let emotion: String
    
    public init(emotion: String) {
        self.emotion = emotion
    }
    
    var emoji: String {
        switch emotion {
        case "행복": return "😊"
        case "기쁨": return "😄"
        case "평온": return "😌"
        case "슬픔": return "😢"
        case "분노": return "😠"
        case "불안": return "😰"
        case "희망": return "🥰"
        default: return "🤔"
        }
    }
    
    var color: Color {
        switch emotion {
        case "행복", "기쁨": return .yellow
        case "평온": return .mint
        case "슬픔": return .blue
        case "분노": return .red
        case "불안": return .purple
        case "희망": return .pink
        default: return .gray
        }
    }
    
    public var body: some View {
        HStack(spacing: 4) {
            Text(emoji)
            Text(emotion)
                .font(.caption.bold())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .foregroundStyle(color)
        .clipShape(Capsule())
    }
}
