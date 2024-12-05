import SwiftUI

/// 빈 상태 뷰
public struct EmptyStateView: View {
    let title: LocalizedStringKey
    let description: LocalizedStringKey
    let buttonTitle: LocalizedStringKey
    let action: () -> Void
    
    public init(
        title: LocalizedStringKey,
        description: LocalizedStringKey,
        buttonTitle: LocalizedStringKey,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.description = description
        self.buttonTitle = buttonTitle
        self.action = action
    }
    
    public var body: some View {
        ContentUnavailableView {
            Label {
                Text(title)
            } icon: {
                Image(systemName: "book.closed")
                    .symbolEffect(.bounce)
                    .foregroundStyle(.pink)
                    .font(.largeTitle)
            }
        } description: {
            Text(description)
                .foregroundStyle(.secondary)
        } actions: {
            Button(action: action) {
                Label(buttonTitle, systemImage: "plus")
                    .font(.body.weight(.medium))
            }
            .buttonStyle(.borderedProminent)
            .tint(.pink)
        }
    }
}
