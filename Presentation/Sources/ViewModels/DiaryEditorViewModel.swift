//
//  DiaryEditorViewModel.swift
//  Feature
//
//  Created by Jeongwan Kim on 11/30/24.
//  Copyright 2024 HowAboutNow. All rights reserved.
//

import SwiftUI
import Domain
import Combine

@MainActor
public final class DiaryEditorViewModel: ObservableObject {
    private let diaryViewModel: DiaryViewModel
    private let diary: Diary?
    
    @Published public var title: String
    @Published public var content: String
    @Published public var date: Date
    @Published public var emotion: String
    @Published public var isEditing: Bool
    @Published public private(set) var isValid = false
    @Published public var alertTitle: LocalizedStringKey = ""
    @Published public var alertMessage: LocalizedStringKey = ""
    @Published public var showAlert = false
    @Published public var isAnalyzing = false
    @Published public var analyzeMessage: String?
    
    @Published var showDatePicker: Bool = false
    @Published var showEmotionPicker: Bool = false
    
    public init(
        diaryViewModel: DiaryViewModel,
        diary: Diary? = nil,
        title: String = "",
        content: String = "",
        date: Date = Date(),
        emotion: String = "",
        isEditing: Bool = false
    ) {
        self.diaryViewModel = diaryViewModel
        self.diary = diary
        self.title = title
        self.content = content
        self.date = date
        self.emotion = emotion
        self.isEditing = isEditing
        
        // 입력값 유효성 검사
        Publishers.CombineLatest($title, $content)
            .map { !$0.isEmpty && !$1.isEmpty }
            .assign(to: &$isValid)
    }
    
    @MainActor
    public func resetAlert() {
        showAlert = false
        alertTitle = ""
        alertMessage = ""
    }
    
    public func save() async -> Bool {
        let existingDiariesForDate = diaryViewModel.diaries.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
        
        // 수정 모드가 아닐 때, 같은 날짜에 일기가 이미 있으면 저장하지 않음
        if !isEditing && !existingDiariesForDate.isEmpty {
            await MainActor.run {
                alertTitle = "이미 작성된 일기가 있습니다"
                alertMessage = "다른 날짜를 선택하고 다시 시도해주세요."
                showAlert = true
                showDatePicker = true
            }
            return false
        }
        
        // 수정 모드일 때, 다른 일기가 있으면 저장하지 않음
        if isEditing && !existingDiariesForDate.isEmpty && existingDiariesForDate[0].id != diary?.id {
            await MainActor.run {
                alertTitle = "이미 작성된 일기가 있습니다"
                alertMessage = "다른 날짜를 선택하고 다시 시도해주세요."
                showAlert = true
                showDatePicker = true
            }
            return false
        }
        
        await MainActor.run {
            isAnalyzing = true
        }
        
        defer {
            Task { @MainActor in
                isAnalyzing = false
            }
        }
        
        if let diary = diary {
            await diaryViewModel.updateDiary(
                diary,
                title: title,
                content: content,
                emotion: emotion
            )
            return true
        } else {
            let diary = Diary(
                id: UUID().uuidString,
                title: title,
                content: content,
                emotion: emotion,
                summary: "",
                date: date
            )
            
            do {
                try await diaryViewModel.saveDiary(diary: diary)
                return true
            } catch {
                print("Error saving diary: \(error)")
                await MainActor.run {
                    alertTitle = "저장 실패"
                    alertMessage = "일기를 저장하는 중에 문제가 발생했습니다. 다시 시도해주세요."
                    showAlert = true
                }
                return false
            }
        }
    }
}
