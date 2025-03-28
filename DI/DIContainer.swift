//
//  DIContainer.swift
//  Data
//
//  Created by 김정완 on 3/28/25.
//  Copyright © 2025 HowAboutNow. All rights reserved.
//

import Foundation
import Data
import Domain

public protocol DIContainerProtocol {
    func resolve<T>(_ type: T.Type) -> T
}

/// 의존성 주입 컨테이너 클래스
/// 앱 전체의 의존성을 관리하고 필요한 객체들을 생성하여 제공합니다.
public final class DIContainer: DIContainerProtocol {
    public static let shared = DIContainer()
    
    private var dependencies: [String: Any] = [:]
    private var isInitialized = false
    
    public init() {}
    
    public func initialize() async {
        guard !isInitialized else { return }
        await registerDependencies()
        isInitialized = true
    }
    
    private func registerDependencies() async {
        let diaryRepository: DiaryRepository = DiaryRepository()
        
        let addDiaryUseCase = AddDiaryUseCase(repository: diaryRepository)
        register(AddDiaryUseCase.self, instance: addDiaryUseCase)
        
        let deleteDiaryUseCase = DeleteDiaryUseCase(repository: diaryRepository)
        register(DeleteDiaryUseCase.self, instance: deleteDiaryUseCase)
        
        let fetchDiaryUseCase = FetchDiaryUseCase(repository: diaryRepository)
        register(FetchDiaryUseCase.self, instance: fetchDiaryUseCase)
        
        let updateDiaryUseCase = UpdateDiaryUseCase(repository: diaryRepository)
        register(UpdateDiaryUseCase.self, instance: updateDiaryUseCase)
        
        let openAIRepository: OpenAIRepository = OpenAIRepository(openAIService: OpenAIService())
        let analysisDiaryUseCase: AnalysisDiaryUseCase = AnalysisDiaryUseCase(repository: openAIRepository)
        register(AnalysisDiaryUseCase.self, instance: analysisDiaryUseCase)
        
        let updateOpenAIConfigurationUseCase: UpdateOpenAIConfigurationUseCase = UpdateOpenAIConfigurationUseCase(repository: openAIRepository)
        register(UpdateOpenAIConfigurationUseCase.self, instance: updateOpenAIConfigurationUseCase)
        
        
        let firestoreRepository = FirestoreRepository(firestoreService: FirestoreService())
        let fetchOpenAIConfigurationUseCase: FetchOpenAIConfigurationUseCase = FetchOpenAIConfigurationUseCase(repository: firestoreRepository)
        register(FetchOpenAIConfigurationUseCase.self, instance: fetchOpenAIConfigurationUseCase)
    }
    
    
    private func register<T>(_ type: T.Type, instance: Any) {
        dependencies[String(describing: type)] = instance
    }
    
    public func resolve<T>(_ type: T.Type) -> T {
        guard isInitialized else {
            fatalError("DIContainer is not initialized")
        }
        
        guard let instance = dependencies[String(describing: type)] as? T else {
            fatalError("No dependency found for \(type)")
        }
        return instance
    }
}

