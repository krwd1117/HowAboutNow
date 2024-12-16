//
//  DiaryDetailViewModel.swift
//  Presentation
//
//  Created by Jeongwan Kim on 12/16/24.
//  Copyright © 2024 HowAboutNow. All rights reserved.
//

import Foundation
import Domain

final class DiaryDetailViewModel: ObservableObject {
    @Published var diary: Diary
    
    private let diContainer: DIContainerProtocol
    
    init(diContainer: DIContainerProtocol, diary: Diary) {
        self.diContainer = diContainer
        self.diary = diary
    }
    
    func deleteDiary() async {
        do {
            try await diContainer.deleteDiaryUseCase.execute(diary: diary)
        } catch {
            
        }
    }
}
