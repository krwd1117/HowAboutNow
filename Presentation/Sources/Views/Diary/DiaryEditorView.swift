import SwiftUI
import UIKit
import Domain

/// 다이어리 작성 및 수정 화면
public struct DiaryEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private var viewModel: DiaryEditorViewModel
    @FocusState private var focusField: Field?
    
    /// 포커스 가능한 필드 정의
    private enum Field {
        case title
        case content
    }
    
    /// 초기화
    /// - Parameter viewModel: 다이어리 편집 ViewModel
    public init(viewModel: DiaryEditorViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    titleSection      // 제목 입력 섹션
                    dateSection      // 날짜 선택 섹션
                    if viewModel.isEditing {
                        emotionSection  // 감정 선택 섹션 (수정 모드에서만 표시)
                    }
                    contentSection   // 내용 입력 섹션
                    
                    // AI 분석 안내 메시지 (새 다이어리 작성 시에만 표시)
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
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            if await viewModel.save() {
                                dismiss()
                            }
                        }
                    } label: {
                        Text(LocalizedStringKey("save"))
                            .fontWeight(.semibold)
                    }
                    .disabled(!viewModel.isValid)
                }
            }
            .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert) {
                Button(LocalizedStringKey("confirm")) {
                    viewModel.resetAlert()
                }
            } message: {
                Text(viewModel.alertMessage)
            }
        }
    }
    
    /// 제목 입력 섹션
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                Text(LocalizedStringKey("title"))
                    .foregroundStyle(.primary)
            } icon: {
                Image(systemName: "pencil")
                    .foregroundStyle(.pink)
            }
            .font(.headline)
            
            TextField(LocalizedStringKey("title_placeholder"), text: $viewModel.title)
                .focused($focusField, equals: .title)
                .textFieldStyle(.roundedBorder)
                .font(.body)
            
            Text(LocalizedStringKey("title_auto_generate"))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    /// 날짜 선택 섹션
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
                withAnimation(.spring(response: 0.3)) {
                    viewModel.showDatePicker.toggle()
                }
            } label: {
                HStack {
                    Text(viewModel.date.formatted(date: .abbreviated, time: .omitted))
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(viewModel.showDatePicker ? 90 : 0))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                )
            }
            .buttonStyle(.plain)
            
            if viewModel.showDatePicker {
                VStack(spacing: 16) {
                    HStack {
                        Text(LocalizedStringKey("select_date"))
                            .font(.headline)
                        Spacer()
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                viewModel.showDatePicker.toggle()
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    DatePicker(
                        "",
                        selection: $viewModel.date,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .tint(.pink)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                )
            }
        }
    }
    
    /// 감정 선택 섹션
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
            
            if viewModel.showEmotionPicker {
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
                    withAnimation(.spring(response: 0.3)) {
                        viewModel.showEmotionPicker.toggle()
                    }
                } label: {
                    HStack {
                        EmotionIcon(emotion: viewModel.emotion, isLoading: viewModel.isAnalyzing)
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
                            .rotationEffect(.degrees(viewModel.showEmotionPicker ? 90 : 0))
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
    
    /// 내용 입력 섹션
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
    
    /// 감정 버튼
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
}
