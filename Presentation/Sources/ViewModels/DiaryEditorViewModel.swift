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
    
    public func save() async {
        if let diary = diary {
            await diaryViewModel.updateDiary(
                diary,
                title: title,
                content: content,
                date: date,
                emotion: emotion
            )
        } else {
            await diaryViewModel.saveDiary(
                title: title,
                content: content,
                date: date
            )
        }
    }
}
