import SwiftUI

/// 감정 아이콘 뷰
public struct EmotionIcon: View {
    /// 감정 텍스트
    let emotion: String
    /// 아이콘 크기
    let size: CGFloat
    /// 로딩 상태
    let isLoading: Bool
    
    /// 초기화
    /// - Parameters:
    ///   - emotion: 감정 텍스트
    ///   - size: 아이콘 크기
    ///   - isLoading: 로딩 상태
    public init(emotion: String, size: CGFloat = 24, isLoading: Bool = false) {
        self.emotion = emotion
        self.size = size
        self.isLoading = isLoading
    }
    
    public var body: some View {
        if isLoading {
            ProgressView()
                .frame(width: size, height: size)
        } else {
            Text(icon)
                .font(.system(size: size))
        }
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
        EmotionIcon(emotion: "happy", isLoading: true)
    }
}
