import SwiftUI
import Combine

import UIKit
import Domain

/// 포커스 가능한 필드 정의
fileprivate enum Field {
    case title
    case content
}

/// 다이어리 작성 및 수정 화면
public struct DiaryEditorView: View {
    @Environment(\.colorScheme) private var colorScheme

    @ObservedObject private var coordinator: DiaryCoordinator
    @StateObject private var viewModel: DiaryEditorViewModel

    @FocusState private var focusField: Field?

    private var editorType: DiaryEditorType
    
    /// 초기화
    /// - Parameter viewModel: 다이어리 편집 ViewModel
    public init(coordinator: DiaryCoordinator, type: DiaryEditorType, diary: Diary?) {
        self.coordinator = coordinator
        self.editorType = type
        self._viewModel = StateObject(wrappedValue: DiaryEditorViewModel(
            diContainer: coordinator.diContainer,
            diary: diary)
        )
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                coordinator: coordinator,
                title: editorType == .new ? "new_diary" : "revisit_diary",
                showBackButton: true,
                rightButton: {
                    AnyView(
                        NavigationBarSaveButton(
                            coordinator: coordinator,
                            viewModel: viewModel
                        )
                    )
                }
            )

            DiaryEditorListView(
                viewModel: viewModel,
                focusField: focusField,
                editorType: editorType
            )
        }
        .navigationBarHidden(true)
    }
}

fileprivate struct NavigationBarSaveButton: View {
    @ObservedObject var coordinator: DiaryCoordinator
    @ObservedObject var viewModel: DiaryEditorViewModel

    var body: some View {
        Button {
            Task {
                _ = await viewModel.save()
                if !viewModel.showAlert {
                    coordinator.pop()
                }
            }
        } label: {
            Text(LocalizedStringKey("save"))
        }
        .disabled(!viewModel.isValid)
    }
}

fileprivate struct DiaryEditorListView: View {
    @ObservedObject private var viewModel: DiaryEditorViewModel
    @FocusState private var focusField: Field?
    @State private var editorType: DiaryEditorType

    init(
        viewModel: DiaryEditorViewModel,
        focusField: Field? = nil,
        editorType: DiaryEditorType
    ) {
        self.viewModel = viewModel
        self.editorType = editorType
        self.focusField = focusField
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 제목 입력 섹션
                TitleSection(viewModel: viewModel, focusField: focusField)

                // 날짜 선택 섹션
                DateSection(viewModel: viewModel)

                // 감정 선택 섹션 (수정 모드에서만 표시)
                if editorType == .edit {
                    EmotionSection(viewModel: viewModel)
                }

                // 내용 입력 섹션
                ContentSection(viewModel: viewModel, focusField: focusField)

                // AI 분석 안내 메시지 (새 다이어리 작성 시에만 표시)
                if editorType == .new {
                    AISummarySection()
                }
            }
            .padding()
        }
        .navigationBarBackButtonHidden(false)
        .environment(\.defaultMinListRowHeight, 0)
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
fileprivate struct TitleSection: View {
    @ObservedObject private var viewModel: DiaryEditorViewModel
    @FocusState private var focusField: Field?

    init(viewModel: DiaryEditorViewModel, focusField: Field? = nil) {
        self.viewModel = viewModel
        self.focusField = focusField
    }

    var body: some View {
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
}

/// 날짜 선택 섹션
fileprivate struct DateSection: View {
    @ObservedObject var viewModel: DiaryEditorViewModel

    init(viewModel: DiaryEditorViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
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
}

/// 감정 선택 섹션
fileprivate struct EmotionSection: View {
    @State private var cancellables: Set<AnyCancellable> = []

    @ObservedObject private var viewModel: DiaryEditorViewModel
    @State private var showEmotionPicker: Bool

    init(viewModel: DiaryEditorViewModel) {
        self.viewModel = viewModel
        self.showEmotionPicker = false

        binding()
    }

    private func binding() {
        viewModel.$emotion
            .receive(on: DispatchQueue.main)
            .sink { emotion in
                print(emotion)
//                self.showEmotionPicker = false
            }
            .store(in: &cancellables)
    }

    var body: some View {
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
                    withAnimation(.spring(response: 0.3)) {
                        showEmotionPicker.toggle()
                    }
                } label: {
                    HStack {
                        EmotionIcon(
                            emotion: viewModel.emotion,
                            isLoading: viewModel.isAnalyzing
                        )
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
}

/// 내용 입력 섹션
fileprivate struct ContentSection: View {
    @ObservedObject var viewModel: DiaryEditorViewModel
    @FocusState var focusField: Field?

    init(viewModel: DiaryEditorViewModel, focusField: Field? = nil) {
        self.viewModel = viewModel
        self.focusField = focusField
    }

    var body: some View {
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
}

/// AI 분석 안내 메시지 섹션
fileprivate struct AISummarySection: View {
    var body: some View {
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

/// 감정 버튼
fileprivate struct EmotionButton: View {
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
