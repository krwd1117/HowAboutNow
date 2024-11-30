import SwiftUI

public struct DiaryEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var viewModel: DiaryEditorViewModel
    @FocusState private var focusField: Field?
    
    private enum Field {
        case title
        case content
    }
    
    public init(viewModel: DiaryEditorViewModel) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    titleSection
                    dateSection
                    contentSection
                    
                    Text("AI가 일기의 감정을 분석해드려요 ✨")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
            .navigationTitle(viewModel.title.isEmpty ? "새로운 일기" : viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                    .foregroundStyle(.secondary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        viewModel.save()
                        dismiss()
                    } label: {
                        Text("저장")
                    }
                    .disabled(!viewModel.isValid)
                    .tint(.pink)
                }
                
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button(action: dismissKeyboard) {
                            Label("키보드 닫기", systemImage: "keyboard.chevron.compact.down.fill")
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .onAppear {
                focusField = viewModel.title.isEmpty ? .title : .content
            }
        }
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("제목", systemImage: "pencil.circle.fill")
                .font(.headline)
                .foregroundStyle(.pink)
            
            TextField("오늘의 제목을 입력해주세요", text: $viewModel.title)
                .font(.body)
                .textFieldStyle(.roundedBorder)
                .focused($focusField, equals: .title)
                .textInputAutocapitalization(.never)
        }
    }
    
    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("날짜", systemImage: "calendar.circle.fill")
                .font(.headline)
                .foregroundStyle(.pink)
            
            HStack {
                Text(viewModel.selectedDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.body)
                
                Spacer()
                
                Button {
                    withAnimation(.spring(duration: 0.3)) {
                        viewModel.toggleDatePicker()
                    }
                } label: {
                    Image(systemName: "calendar")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.pink)
                }
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.background)
                    .shadow(color: .black.opacity(0.03), radius: 8, y: 4)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(.quaternary, lineWidth: 0.5)
            }
            
            if viewModel.showDatePicker {
                DatePicker(
                    "날짜 선택",
                    selection: $viewModel.selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .tint(.pink)
                .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
            }
        }
    }
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("내용", systemImage: "text.bubble.fill")
                .font(.headline)
                .foregroundStyle(.pink)
            
            TextEditor(text: $viewModel.content)
                .font(.body)
                .focused($focusField, equals: .content)
                .frame(minHeight: 200)
                .scrollContentBackground(.hidden)
                .padding(12)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.background)
                        .shadow(color: .black.opacity(0.03), radius: 8, y: 4)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(.quaternary, lineWidth: 0.5)
                }
        }
    }
    
    private func dismissKeyboard() {
        focusField = nil
    }
}

#Preview {
    DiaryEditorView(viewModel: DiaryEditorViewModel(title: "", content: "", date: .now, onSave: { title, content, date in
        print("Title:", title)
        print("Content:", content)
        print("Date:", date)
    }))
}
