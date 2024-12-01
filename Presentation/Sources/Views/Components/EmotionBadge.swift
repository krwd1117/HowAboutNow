import SwiftUI

public struct EmotionBadge: View {
    let emotion: String
    
    public init(emotion: String) {
        self.emotion = emotion
    }
    
    var emoji: String {
        switch emotion {
        case "happy": return "😊"
        case "joy": return "😄"
        case "peaceful": return "😌"
        case "sad": return "😢"
        case "angry": return "😠"
        case "anxious": return "😰"
        case "hopeful": return "🥰"
        default: return "🤔"
        }
    }
    
    var color: Color {
        switch emotion {
        case "happy", "joy": return .yellow
        case "peaceful": return .mint
        case "sad": return .blue
        case "angry": return .red
        case "anxious": return .purple
        case "hopeful": return .pink
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

#Preview {
    VStack(spacing: 8) {
        EmotionBadge(emotion: "happy")
        EmotionBadge(emotion: "joy")
        EmotionBadge(emotion: "peaceful")
        EmotionBadge(emotion: "sad")
        EmotionBadge(emotion: "angry")
        EmotionBadge(emotion: "anxious")
        EmotionBadge(emotion: "hopeful")
        EmotionBadge(emotion: "unknown")
    }
    .padding()
}
