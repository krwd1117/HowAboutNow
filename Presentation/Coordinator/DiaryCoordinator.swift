//
//  DiaryCoordinator.swift
//  Presentation
//
//  Created by Jeongwan Kim on 12/16/24.
//  Copyright © 2024 HowAboutNow. All rights reserved.
//

import SwiftUI
import Domain

public enum DiaryEditorType {
    case new
    case edit
}

public enum DiaryRoute: Identifiable, Hashable {
    case list // 일기 목록
    case detail(Diary) // 일기 상세보기
    case editor(DiaryEditorType, Diary?) // 일기 작성 및 수정

    public var id: String {
        switch self {
        case .list:
            return "list"
        case .detail(let diary):
            return diary.id
        case .editor(_, let diary):
            return diary?.id ?? UUID().uuidString
        }
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public final class DiaryCoordinator: CoordinatorProtocol {

    @Published public var navigationPath: [DiaryRoute] = []

    let diContainer: DIContainerProtocol
    
    public init(diContainer: DIContainerProtocol) {
        self.diContainer = diContainer
    }
    
    func navigateBackToList() {
        navigationPath = []
    }

    // 화면이동
    public func push(route: DiaryRoute) {
        navigationPath.append(route)
    }

    // 뒤로가기
    public func pop() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast() // 뒤로가기 로직
        }
    }
}
