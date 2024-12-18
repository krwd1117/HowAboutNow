//
//  FetchDiaryUseCase.swift
//  Domain
//
//  Created by Jeongwan Kim on 12/18/24.
//  Copyright © 2024 HowAboutNow. All rights reserved.
//

import Foundation

public protocol FetchDiaryUseCaseProtocol {
    func execute(diary: Diary) async throws -> Diary?
}

public final class FetchDiaryUseCase: FetchDiaryUseCaseProtocol {
    private let repository: DiaryRepositoryProtocol

    public init(repository: DiaryRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(diary: Diary) async throws -> Diary? {
        try await repository.fetchDiary(diary: diary)
    }
}

