//
//  DiaryRootView.swift
//  Presentation
//
//  Created by Jeongwan Kim on 12/16/24.
//  Copyright © 2024 HowAboutNow. All rights reserved.
//

import SwiftUI

struct DiaryRootView: View {
    @ObservedObject private var coordinator: DiaryCoordinator
    
    /// 초기화
    public init(coordinator: DiaryCoordinator) {
        self.coordinator = coordinator
    }

    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            VStack {
                DiaryListView(coordinator: coordinator) // 다이어리 목록 화면
            }
            .navigationDestination(for: DiaryRoute.self) { route in
                switch route {
                case .list:
                    EmptyView()
                case .detail(let diary):
                    DiaryDetailView(coordinator: coordinator, diary: diary)
                case .editor(let type, let diary):
                    DiaryEditorView(coordinator: coordinator, type: type, diary: diary)
                }
            }
            .navigationBarHidden(true)
        }
    }
}
