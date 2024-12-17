//
//  CustomNavigationBar.swift
//  Presentation
//
//  Created by Jeongwan Kim on 12/17/24.
//  Copyright © 2024 HowAboutNow. All rights reserved.
//

import SwiftUI

struct CustomNavigationBar: View {
    var coordinator: any CoordinatorProtocol

    let title: String
    let showBackButton: Bool
    let rightButton: (() -> AnyView)?

    init(
        coordinator: any CoordinatorProtocol,
        title: String,
        showBackButton: Bool,
        rightButton: (() -> AnyView)? = nil
    ) {
        self.coordinator = coordinator
        self.title = title
        self.showBackButton = showBackButton
        self.rightButton = rightButton
    }

    var body: some View {
        HStack {
            if showBackButton {
                Button(action: {
                    coordinator.pop()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }

            Spacer()

            Text(LocalizedStringKey(title))
                .font(.headline)
                .bold()

            Spacer()

            if let rightButton {
                rightButton()
            } else if showBackButton {
                Color.clear.frame(width: 24) // 균형 맞춤용
            }
        }
        .padding()
        .background(.white)
        .frame(height: 44)
    }
}
