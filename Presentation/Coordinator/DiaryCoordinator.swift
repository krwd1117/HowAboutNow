//
//  DiaryCoordinator.swift
//  Presentation
//
//  Created by Jeongwan Kim on 12/16/24.
//  Copyright © 2024 HowAboutNow. All rights reserved.
//

import SwiftUI
import Domain

public final class DiaryCoordinator: ObservableObject {
    
    enum DiaryView {
        case list // 일기 목록
        case detail(Diary) // 일기 상세보기
        case editor // 일기 작성 및 수정
    }
    
    @Published var currentView: DiaryView = .list // 현재 선택 된 탭
    
    private let diContainer: DIContainerProtocol
    
    public init(diContainer: DIContainerProtocol) {
        self.diContainer = diContainer
    }
    
    func navigateBackToList() {
        currentView = .list
    }
    
    func navigateToDetail(diary: Diary) {
        currentView = .detail(diary)
    }
    
    func navigateToEditor() {
        currentView = .editor
    }
}
