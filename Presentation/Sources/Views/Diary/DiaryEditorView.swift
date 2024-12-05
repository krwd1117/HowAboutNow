import SwiftUI
import UIKit

public struct DiaryEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private var viewModel: DiaryEditorViewModel
    @FocusState private var focusField: Field?
    @State private var showDatePicker = false
    @State private var showEmotionPicker = false
    
    private enum Field {
        case title
        case content
    }
    
    public init(viewModel: DiaryEditorViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    titleSection
                    dateSection
                    if viewModel.isEditing {
                        emotionSection
                    }
                    contentSection
                    
                    if !viewModel.isEditing {
                        VStack(spacing: 8) {
                            HStack(spacing: 4) {
                                Image(systemName: "wand.and.stars")
                                    .symbolEffect(.bounce)
                                Text(LocalizedStringKey("ai_analyze_emotion"))
                            }
                            .font(.subheadline)
                            .foregroundStyle(.pink)
                            
                            Text(LocalizedStringKey("ai_analyze_description"))
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
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle(LocalizedStringKey(viewModel.title.isEmpty ? "new_diary" : viewModel.title))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(LocalizedStringKey("cancel")) {
                        dismiss()
                    }
                    .foregroundStyle(.secondary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        viewModel.save()
                        dismiss()
                    } label: {
                        Text(LocalizedStringKey("save"))
                            .fontWeight(.medium)
                    }
                    .disabled(!viewModel.isValid)
                    .tint(.pink)
                }
                
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button(action: dismissKeyboard) {
                            Label(LocalizedStringKey("dismiss_keyboard"), systemImage: "keyboard.chevron.compact.down.fill")
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
                Text(LocalizedStringKey("title"))
                    .foregroundStyle(.primary)
            } icon: {
                Image(systemName: "pencil")
                    .foregroundStyle(.pink)
            }
            
            TextField("title_placeholder", text: $viewModel.title)
                .focused($focusField, equals: .title)
                .font(.headline)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                )
        }
    }
    
    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                Text(LocalizedStringKey("date"))
                    .foregroundStyle(.primary)
            } icon: {
                Image(systemName: "calendar")
                    .foregroundStyle(.pink)
            }
            
            Button {
                dismissKeyboard()
                withAnimation(.spring(response: 0.3)) {
                    showDatePicker.toggle()
                }
            } label: {
                HStack {
                    Text(viewModel.selectedDate.formatted(date: .abbreviated, time: .omitted))
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(showDatePicker ? 90 : 0))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                )
            }
            .buttonStyle(.plain)
            
            if showDatePicker {
                DatePicker(
                    "",
                    selection: $viewModel.selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                )
            }
        }
    }
    
    private var emotionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label {
                Text(LocalizedStringKey("emotion"))
                    .font(.headline)
            } icon: {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.pink)
                    .symbolEffect(.bounce)
            }
            
            if showEmotionPicker {
                VStack(spacing: 12) {
                    Text(LocalizedStringKey("select_emotion"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        EmotionButton(emotion: "happy", selectedEmotion: $viewModel.emotion)
                        EmotionButton(emotion: "joy", selectedEmotion: $viewModel.emotion)
                        EmotionButton(emotion: "peaceful", selectedEmotion: $viewModel.emotion)
                        EmotionButton(emotion: "hopeful", selectedEmotion: $viewModel.emotion)
                        EmotionButton(emotion: "sad", selectedEmotion: $viewModel.emotion)
                        EmotionButton(emotion: "angry", selectedEmotion: $viewModel.emotion)
                        EmotionButton(emotion: "anxious", selectedEmotion: $viewModel.emotion)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                )
            } else {
                Button {
                    dismissKeyboard()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showEmotionPicker.toggle()
                    }
                } label: {
                    HStack {
                        EmotionIcon(emotion: viewModel.emotion)
                            .font(.title)
                            .symbolEffect(.bounce)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(LocalizedStringKey(viewModel.emotion))
                                .font(.headline)
                            Text(LocalizedStringKey("tap_to_change"))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .rotationEffect(.degrees(showEmotionPicker ? 90 : 0))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color(uiColor: .secondarySystemGroupedBackground))
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                Text(LocalizedStringKey("content"))
                    .foregroundStyle(.primary)
            } icon: {
                Image(systemName: "text.alignleft")
                    .foregroundStyle(.pink)
            }
            
            TextEditor(text: $viewModel.content)
                .focused($focusField, equals: .content)
                .frame(minHeight: 240)
                .padding()
                .scrollContentBackground(.hidden)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                )
        }
    }
    
    private struct EmotionButton: View {
        let emotion: String
        @Binding var selectedEmotion: String
        
        var body: some View {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedEmotion = emotion
                }
            } label: {
                VStack(spacing: 8) {
                    EmotionIcon(emotion: emotion)
                        .font(.title2)
                    
                    Text(LocalizedStringKey(emotion))
                        .font(.caption)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(selectedEmotion == emotion ? 
                            Color.pink.opacity(0.15) : 
                            Color(uiColor: .tertiarySystemGroupedBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(selectedEmotion == emotion ? 
                            Color.pink.opacity(0.3) : Color.clear,
                            lineWidth: 1.5)
                )
            }
            .foregroundStyle(selectedEmotion == emotion ? .pink : .primary)
        }
    }
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), 
                                     to: nil, 
                                     from: nil, 
                                     for: nil)
    }
}

#Preview {
    DiaryEditorView(viewModel: DiaryEditorViewModel(
        title: "",
        content: "",
        date: .now,
        onSave: { _, _, _, _ in },
        onDatePickerToggle: { _ in }
    ))
}
