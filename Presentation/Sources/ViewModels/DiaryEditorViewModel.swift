//
//  DiaryEditorViewModel.swift
//  Feature
//
//  Created by Jeongwan Kim on 11/30/24.
//  Copyright 2024 HowAboutNow. All rights reserved.
//

import Foundation
import Combine

@MainActor
public final class DiaryEditorViewModel: ObservableObject {
    @Published public var title: String
    @Published public var content: String
    @Published public var selectedDate: Date
    @Published public var showDatePicker = false
    @Published public private(set) var isValid = false
    
    private let onSave: (String, String, Date) -> Void
    private var cancellables = Set<AnyCancellable>()
    
    public init(
        title: String = "",
        content: String = "",
        date: Date = .now,
        onSave: @escaping (String, String, Date) -> Void
    ) {
        self.title = title
        self.content = content
        self.selectedDate = date
        self.onSave = onSave
        
        // 입력값 유효성 검사
        Publishers.CombineLatest($title, $content)
            .map { !$0.isEmpty && !$1.isEmpty }
            .assign(to: &$isValid)
        
        // 날짜가 변경되면 300ms 후에 데이트피커를 닫습니다
        $selectedDate
            .dropFirst()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.showDatePicker = false
            }
            .store(in: &cancellables)
    }
    
    public func toggleDatePicker() {
        showDatePicker.toggle()
    }
    
    public func save() {
        onSave(title, content, selectedDate)
    }
}
