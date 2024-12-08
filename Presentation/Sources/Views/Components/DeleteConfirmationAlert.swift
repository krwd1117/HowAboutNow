import SwiftUI
import Domain

public struct DeleteConfirmationAlert {
    let viewModel: DiaryViewModel
    let diary: Diary
    let isPresented: Binding<Bool>
    let onComplete: () -> Void
    
    public init(
        viewModel: DiaryViewModel,
        diary: Diary,
        isPresented: Binding<Bool>,
        onComplete: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.diary = diary
        self.isPresented = isPresented
        self.onComplete = onComplete
    }
    
    public var alert: Alert {
        Alert(
            title: Text(LocalizedStringKey("delete_diary_confirm")),
            message: Text(LocalizedStringKey("delete_diary_message")),
            primaryButton: .destructive(Text(LocalizedStringKey("delete"))) {
                Task {
                    await viewModel.deleteDiary(diary)
                    onComplete()
                }
            },
            secondaryButton: .cancel(Text(LocalizedStringKey("cancel")))
        )
    }
}
