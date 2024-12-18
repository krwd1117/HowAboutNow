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

public final class DiaryEditorViewModel: ObservableObject {

    enum DiaryEditorError: Error {
        case duplicateDiary
        case saveFailed
        case updateFailed
    }

    private let diContainer: DIContainerProtocol

    @Published private var diary: Diary?
    @Published private var editorType: DiaryEditorType?

    @Published public var title: String = ""
    @Published public var content: String = ""
    @Published public var date: Date = Date()
    @Published public var emotion: String = ""

    @Published public var alertTitle: LocalizedStringKey = ""
    @Published public var alertMessage: LocalizedStringKey = ""
    @Published public var showAlert = false

//    @Published private var analyzeMessage: String?

    @Published public var isAnalyzing = false
    @Published public private(set) var isValid = false

//    @Published var showDatePicker: Bool = false
//    @Published var showEmotionPicker: Bool = false

    public init(
        diContainer: DIContainerProtocol,
        diary: Diary?
    ) {
        self.diContainer = diContainer
        self.diary = diary

        if let diary {
            self.title = diary.title
            self.content = diary.content
            self.date = diary.date
            self.emotion = diary.emotion
        }

        setupBindings()
    }

    private func setupBindings() {
        $content
            .map { !$0.isEmpty }
            .assign(to: &$isValid)
    }

    private func validateDiarySave() async throws {
        guard diary != nil else {
            // 새롭게 저장
            let diaries = try await diContainer.fetchDiariesUseCase.execute()
            // 등록하려는 날짜에 일기가 등록 되어있는지 확인
            let existingDiariesForDate = diaries.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }

            // 이미 등록된 일기가 있다면 에러를 반환
            if !existingDiariesForDate.isEmpty {
                throw DiaryEditorError.duplicateDiary
            }
            return
        }
    }

    public func addButtonTapped() async {
        do {
            try await validateDiarySave()
            if let diary {
                try await update(diary: diary)
            } else {
                try await add()
            }
        } catch DiaryEditorError.duplicateDiary {
            alertTitle = "diary_exists_title"
            alertMessage = "diary_exists_select_another_date"
            showAlert = true
        } catch DiaryEditorError.saveFailed {
            alertTitle = "save_failed_title"
            alertMessage = "save_failed_message"
            showAlert = true
        } catch DiaryEditorError.updateFailed {
            alertTitle = "update_failed_title"
            alertMessage = "update_failed_message"
            showAlert = true
        } catch {
            alertTitle = "error_title"
            alertMessage = "error_message"
            showAlert = true
        }
    }

    @MainActor
    public func reloadDiary() async throws {
        guard let diary = diary else { return }
        self.diary = try await diContainer.fetchDiaryUseCase.execute(diary: diary)
    }

    private func update(diary: Diary) async throws {
        do {
            let updatedDiary = Diary(
                id: diary.id,
                title: self.title,
                content: self.content,
                emotion: self.emotion,
                date: self.date
            )
            try await diContainer.updateDiaryUseCase.execute(diary: updatedDiary)

            Task.detached { [weak self] in
                guard let self else { return }
                await self.analyzeDiary(diary: updatedDiary)
            }
        } catch {
            throw DiaryEditorError.updateFailed
        }
    }

    private func add() async throws {
        do {
            let diary = Diary(
                title: self.title,
                content: self.content,
                date: self.date
            )
            try await diContainer.addDiaryUseCase.execute(diary: diary)

            Task.detached { [weak self] in
                guard let self else { return }
                await self.analyzeDiary(diary: diary)
            }
        } catch {
            throw DiaryEditorError.saveFailed
        }
    }

    private func analyzeDiary(diary: Diary) async {
        // 백그라운드에서 감정 분석 수행
        do {
            let analysis = try await diContainer.analyzeDiaryUseCase.excute(diary: diary)

            guard let analysis = analysis else {
                return
            }

            let analyzedDiary = Diary(
                id: diary.id,
                title: diary.title.isEmpty ? analysis.title : diary.title,
                content: diary.content,
                emotion: analysis.emotion,
                summary: analysis.summary,
                date: diary.date
            )

            try await diContainer.updateDiaryUseCase.execute(diary: analyzedDiary)
        } catch {
            print("Error analyzing diary: \(error)")
        }
    }
}
