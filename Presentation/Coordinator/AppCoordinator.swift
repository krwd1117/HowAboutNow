//
//  AppCoordinator.swift
//  Data
//
//  Created by Jeongwan Kim on 12/16/24.
//  Copyright © 2024 HowAboutNow. All rights reserved.
//

import SwiftUI

public final class AppCoordinator: ObservableObject {
    
    public enum AppView {
        case splash
        case mainTab
    }
    
    @Published public var currentView: AppView = .splash // 초기 값 설정
    
    private let diContainer: DIContainerProtocol
    
    public init(diContainer: DIContainerProtocol) {
        self.diContainer = diContainer
    }
    
    public func start() {
        self.currentView = .splash
    }
    
    public func navitateToMainTab() {
        self.currentView = .mainTab
    }
}
