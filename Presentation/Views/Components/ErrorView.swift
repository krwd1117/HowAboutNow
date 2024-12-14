import SwiftUI

/// 에러 표시 뷰
public struct ErrorView: View {
    /// 에러 메시지
    let message: String
    
    public init(message: String) {
        self.message = message
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.red)
            
            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview {
    ErrorView(message: "Something went wrong")
}
