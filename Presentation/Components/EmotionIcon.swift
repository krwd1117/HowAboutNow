import SwiftUI

/// 감정 아이콘 뷰
public struct EmotionIcon: View {
    let emotion: String
    let size: CGFloat
    let isLoading: Bool

    public init(
        emotion: String,
        size: CGFloat = 24,
        isLoading: Bool = false
    ) {
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
