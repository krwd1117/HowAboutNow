import SwiftUI
import Domain

public struct DiaryEditorSheet: View {
    let diary: Diary?
    let date: Date
    let onSave: (String, String, Date, String) -> Void
    
    public init(
        diary: Diary? = nil,
        date: Date = Date(),
        onSave: @escaping (String, String, Date, String) -> Void
    ) {
        self.diary = diary
        self.date = date
        self.onSave = onSave
    }
    
    public var body: some View {
        NavigationStack {
            DiaryEditorView(
                viewModel: DiaryEditorViewModel(
                    title: diary?.title ?? "",
                    content: diary?.content ?? "",
                    date: diary?.date ?? date,
                    emotion: diary?.emotion ?? "",
                    isEditing: diary != nil,
                    onSave: onSave,
                    onDatePickerToggle: { _ in }
                )
            )
        }
    }
}
