import SwiftUI

/// 감정 아이콘 뷰
public struct EmotionIcon: View {
    /// 감정 텍스트
    let emotion: String
    /// 아이콘 크기
    let size: CGFloat
    
    /// 초기화
    /// - Parameters:
    ///   - emotion: 감정 텍스트
    ///   - size: 아이콘 크기
    public init(emotion: String, size: CGFloat = 24) {
        self.emotion = emotion
        self.size = size
    }
    
    public var body: some View {
        Text(icon)
            .font(.system(size: size))
    }
    
    private var icon: String {
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
}

#Preview {
    VStack {
        EmotionIcon(emotion: "happy")
        EmotionIcon(emotion: "joy")
        EmotionIcon(emotion: "peaceful")
        EmotionIcon(emotion: "sad")
        EmotionIcon(emotion: "angry")
        EmotionIcon(emotion: "anxious")
        EmotionIcon(emotion: "hopeful")
        EmotionIcon(emotion: "unknown")
    }
}
