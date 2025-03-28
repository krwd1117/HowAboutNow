//
//  DiaryEditorViewModel.swift
//  Feature
//
//  Created by Jeongwan Kim on 11/30/24.
//  Copyright 2024 HowAboutNow. All rights reserved.
//

import Foundation

//import SwiftUI
import Domain
import Combine

@MainActor
public final class DiaryEditorViewModel: ObservableObject {
    private let diaryViewModel: DiaryViewModel
    @Published var diary: Diary?
    
    @Published var title: String = ""
    @Published var content: String = ""
    @Published var date: Date = Date()
    @Published var emotion: String = ""
    @Published var isEditing: Bool = false
    
    @Published private(set) var isValid = false
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    @Published var showAlert = false
    @Published var isAnalyzing = false
    @Published var analyzeMessage: String? = nil
    
    @Published var showDatePicker: Bool = false
    @Published var showEmotionPicker: Bool = false
    
    public init(
        diaryViewModel: DiaryViewModel,
        diary: Diary? = nil,
        isEditing: Bool = false
    ) {
        self.diaryViewModel = diaryViewModel
        self.diary = diary
        
        if let diary = diary {
            self.title = diary.title
            self.content = diary.content
            self.date = diary.date
            self.emotion = diary.emotion
        }
        
        self.isEditing = isEditing
        
        // 입력값 유효성 검사 - 내용만 필수로 변경
        $content
            .map { !$0.isEmpty }
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
                alertTitle = "diary_exists_title"
                alertMessage = "diary_exists_select_another_date"
                showAlert = true
                showDatePicker = true
            }
            return false
        }
        
        // 수정 모드일 때, 다른 일기가 있으면 저장하지 않음
        if isEditing && !existingDiariesForDate.isEmpty && existingDiariesForDate[0].id != diary?.id {
            await MainActor.run {
                alertTitle = "diary_exists_title"
                alertMessage = "diary_exists_select_another_date"
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
                emotion: emotion,
                date: date
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
                    alertTitle = "save_failed_title"
                    alertMessage = "save_failed_message"
                    showAlert = true
                }
                return false
            }
        }
    }
}
