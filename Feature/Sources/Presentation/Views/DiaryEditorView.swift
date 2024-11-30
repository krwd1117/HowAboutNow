import SwiftUI

public struct DiaryEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool
    
    let content: String
    let onSave: (String) -> Void
    
    @State private var editedContent: String
    
    public init(content: String, onSave: @escaping (String) -> Void) {
        self.content = content
        self.onSave = onSave
        self._editedContent = State(initialValue: content)
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                TextField("오늘 하루는 어땠나요?", text: $editedContent, axis: .vertical)
                    .lineLimit(5...10)
                    .focused($isFocused)
            }
            .navigationTitle(content.isEmpty ? "새 일기" : "일기 수정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        onSave(editedContent)
                        dismiss()
                    }
                    .disabled(editedContent.isEmpty)
                }
            }
            .onAppear {
                isFocused = true
            }
        }
    }
}

#Preview {
    DiaryEditorView(content: "") { _ in }
}
