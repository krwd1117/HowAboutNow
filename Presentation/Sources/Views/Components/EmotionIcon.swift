import SwiftUI

struct EmotionIcon: View {
    let emotion: String
    
    var body: some View {
        Text(icon)
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
