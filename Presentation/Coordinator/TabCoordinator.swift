//
//  TabCoordinator.swift
//  Presentation
//
//  Created by Jeongwan Kim on 12/16/24.
//  Copyright © 2024 HowAboutNow. All rights reserved.
//

import SwiftUI

public final class BottomTabCoordinator: ObservableObject {
    enum Tab {
        case diary
        case setting
    }
    
    @Published var selectedTab: Tab = .diary // 현재 선택 된 탭
    
    private let diContainer: DIContainerProtocol
    
    public init(diContainer: DIContainerProtocol) {
        self.diContainer = diContainer
    }
    
    func switchToDiary() {
        guard selectedTab != .diary else { return }
        selectedTab = .diary
    }
    
    func switchToSetting() {
        guard selectedTab != .setting else { return }
        selectedTab = .setting
    }
}
