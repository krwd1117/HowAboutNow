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
            title: Text("delete_diary"),
            message: Text("delete_diary_confirm"),
            primaryButton: .destructive(Text("delete")) {
                Task {
                    await viewModel.deleteDiary(diary)
                    onComplete()
                }
            },
            secondaryButton: .cancel(Text("cancel"))
        )
    }
}
