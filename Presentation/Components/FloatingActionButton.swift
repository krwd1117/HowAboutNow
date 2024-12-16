import SwiftUI

/// 플로팅 액션 버튼
public struct FloatingActionButton<Destination: View>: View {
    let destination: Destination
    
    public init(destination: Destination) {
        self.destination = destination
    }
    
    public var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                NavigationLink {
                    destination
                } label: {
                    Image(systemName: "plus")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.pink, .pink.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        )
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                }
                .buttonStyle(BounceButtonStyle())
                .padding()
            }
        }
    }
}

/// 바운스 버튼 스타일
public struct BounceButtonStyle: ButtonStyle {
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
