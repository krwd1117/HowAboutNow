import SwiftUI

/// 빈 상태 뷰
public struct EmptyStateView: View {
    let viewModel: DiaryViewModel
    let title: LocalizedStringKey
    let description: LocalizedStringKey
    let buttonTitle: LocalizedStringKey
    let action: () -> Void
    
    public init(
        viewModel: DiaryViewModel,
        title: LocalizedStringKey,
        description: LocalizedStringKey,
        buttonTitle: LocalizedStringKey,
        action: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.title = title
        self.description = description
        self.buttonTitle = buttonTitle
        self.action = action
    }
    
    public var body: some View {
        ContentUnavailableView(label: {
            Label(
                title: {
                    Text(title)
                }, icon: {
                    Image(systemName: "book.closed")
                        .foregroundStyle(.pink)
                        .font(.largeTitle)
                })
        }, description: {
            Text(description)
        })
    }
}
