import SwiftUI
import UIKit

public struct DiaryEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private var viewModel: DiaryEditorViewModel
    @FocusState private var focusField: Field?
    @State private var showDatePicker = false
    
    private enum Field {
        case title
        case content
    }
    
    public init(viewModel: DiaryEditorViewModel) {
        let onSave = viewModel.onSave
        self._viewModel = ObservedObject(wrappedValue: DiaryEditorViewModel(
            title: viewModel.title,
            content: viewModel.content,
            date: viewModel.selectedDate,
            onSave: { title, content, date in
                onSave(title, content, date)
            },
            onDatePickerToggle: { isShowing in
                if isShowing {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), 
                                                 to: nil, 
                                                 from: nil, 
                                                 for: nil)
                }
            }
        ))
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    titleSection
                    dateSection
                    contentSection
                    
                    VStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Image(systemName: "wand.and.stars")
                                .symbolEffect(.bounce)
                            Text("AI가 일기의 감정을 분석해드려요")
                        }
                        .font(.subheadline)
                        .foregroundStyle(.pink)
                        
                        Text("일기를 저장하면 AI가 감정을 분석하고 요약해드려요")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.pink.opacity(0.1))
                    )
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground))
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
                            .fontWeight(.medium)
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
            Label {
                Text("제목")
                    .foregroundStyle(.primary)
            } icon: {
                Image(systemName: "pencil.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.pink)
            }
            .font(.headline)
            
            TextField("오늘의 제목을 입력해주세요", text: $viewModel.title)
                .font(.body)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                )
                .focused($focusField, equals: .title)
                .textInputAutocapitalization(.never)
        }
    }
    
    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                Text("날짜")
                    .foregroundStyle(.primary)
            } icon: {
                Image(systemName: "calendar.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.pink)
            }
            .font(.headline)
            
            HStack {
                Text(formatDate(viewModel.selectedDate))
                    .font(.body)
                
                Spacer()
                
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        showDatePicker.toggle()
                        if showDatePicker {
                            focusField = nil
                        }
                    }
                } label: {
                    Image(systemName: "calendar")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.pink)
                        .font(.body.weight(.medium))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
            )
            
            if showDatePicker {
                DatePicker(
                    "날짜 선택",
                    selection: $viewModel.selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
                .onChange(of: viewModel.selectedDate) { _ in
                    withAnimation(.spring(response: 0.3)) {
                        showDatePicker = false
                    }
                }
            }
        }
    }
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                Text("내용")
                    .foregroundStyle(.primary)
            } icon: {
                Image(systemName: "text.bubble.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.pink)
            }
            .font(.headline)
            
            TextEditor(text: $viewModel.content)
                .font(.body)
                .frame(minHeight: 200)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                )
                .focused($focusField, equals: .content)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(date) {
            return "오늘"
        } else if calendar.isDateInYesterday(date) {
            return "어제"
        } else if calendar.isDateInTomorrow(date) {
            return "내일"
        }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        
        if calendar.component(.year, from: date) == calendar.component(.year, from: now) {
            formatter.dateFormat = "M월 d일 (E)"
        } else {
            formatter.dateFormat = "yyyy년 M월 d일 (E)"
        }
        
        return formatter.string(from: date)
    }
    
    private func dismissKeyboard() {
        focusField = nil
    }
}

#Preview {
    DiaryEditorView(viewModel: DiaryEditorViewModel(
        title: "",
        content: "",
        date: Date(),
        onSave: { _, _, _ in },
        onDatePickerToggle: { _ in }
    ))
}
