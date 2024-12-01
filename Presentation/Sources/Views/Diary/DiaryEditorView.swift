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
                            Text("ai_analyze_emotion")
                        }
                        .font(.subheadline)
                        .foregroundStyle(.pink)
                        
                        Text("ai_analyze_description")
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
            .navigationTitle(LocalizedStringKey(viewModel.title.isEmpty ? "new_diary" : viewModel.title))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.secondary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        viewModel.save()
                        dismiss()
                    } label: {
                        Text("save")
                            .fontWeight(.medium)
                    }
                    .disabled(!viewModel.isValid)
                    .tint(.pink)
                }
                
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button(action: dismissKeyboard) {
                            Label("dismiss_keyboard", systemImage: "keyboard.chevron.compact.down.fill")
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
                Text("title")
                    .foregroundStyle(.primary)
            } icon: {
                Image(systemName: "pencil.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.pink)
            }
            .font(.headline)
            
            TextField("title_placeholder", text: $viewModel.title)
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
                Text("date")
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
                    "date",
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
                Text("content")
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
            return String(localized: "today")
        } else if calendar.isDateInYesterday(date) {
            return String(localized: "yesterday")
        } else if calendar.isDateInTomorrow(date) {
            return String(localized: "tomorrow")
        }
        
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        
        if calendar.component(.year, from: date) == calendar.component(.year, from: now) {
            formatter.dateFormat = String(localized: "date_format_current_year")
        } else {
            formatter.dateFormat = String(localized: "date_format_other_year")
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
