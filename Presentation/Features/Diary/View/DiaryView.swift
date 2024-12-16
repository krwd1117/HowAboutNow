//
//  DiaryView.swift
//  Presentation
//
//  Created by Jeongwan Kim on 12/16/24.
//  Copyright © 2024 HowAboutNow. All rights reserved.
//

import SwiftUI

struct DiaryView: View {
    @EnvironmentObject private var diaryCoordinator: DiaryCoordinator
    
    private let diContainer: DIContainerProtocol
    
    /// 초기화
    public init(diContainer: DIContainerProtocol) {
        self.diContainer = diContainer
    }

    var body: some View {
        Group {
            switch diaryCoordinator.currentView {
            case .list:
                let viewModel = DiaryListViewModel(diContainer: diContainer)
                DiaryListView(viewModel: viewModel) // 다이어리 목록 화면
                    .environmentObject(diaryCoordinator)
                
            case .detail(let diary):
                let viewModel = DiaryDetailViewModel(diContainer: diContainer, diary: diary)
                DiaryDetailView(viewModel: viewModel)
                    .environmentObject(diaryCoordinator)
                
            case .editor:
                EmptyView()
            }
        }
    }
}
