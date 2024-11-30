import SwiftUI

public struct DiaryEditorView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String
    @State private var content: String
    @State private var date: Date
    @FocusState private var focusField: Field?
    
    private let onSave: (String, String, Date) -> Void
    
    private enum Field {
        case title
        case content
    }
    
    public init(
        title: String = "",
        content: String = "",
        date: Date = .now,
        onSave: @escaping (String, String, Date) -> Void
    ) {
        _title = State(initialValue: title)
        _content = State(initialValue: content)
        _date = State(initialValue: date)
        self.onSave = onSave
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("제목", text: $title)
                        .focused($focusField, equals: .title)
                        .textInputAutocapitalization(.never)
                    
                    DatePicker(
                        "날짜",
                        selection: $date,
                        displayedComponents: [.date]
                    )
                }
                
                Section {
                    TextEditor(text: $content)
                        .focused($focusField, equals: .content)
                        .frame(minHeight: 200)
                } header: {
                    Text("내용")
                } footer: {
                    Text("AI가 일기의 감정을 분석합니다")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(title.isEmpty ? "새 일기" : title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        onSave(title, content, date)
                        dismiss()
                    }
                    .disabled(title.isEmpty || content.isEmpty)
                }
                
                ToolbarItem(placement: .keyboard) {
                    Button(action: dismissKeyboard) {
                        Label("키보드 닫기", systemImage: "keyboard.chevron.compact.down")
                    }
                }
            }
            .onAppear {
                focusField = title.isEmpty ? .title : .content
            }
        }
    }
    
    private func dismissKeyboard() {
        focusField = nil
    }
}

#Preview {
    DiaryEditorView { title, content, date in
        print("Title:", title)
        print("Content:", content)
        print("Date:", date)
    }
}
