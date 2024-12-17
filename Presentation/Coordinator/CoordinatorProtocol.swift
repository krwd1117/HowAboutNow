//
//  CoordinatorProtocol.swift
//  Data
//
//  Created by Jeongwan Kim on 12/16/24.
//  Copyright © 2024 HowAboutNow. All rights reserved.
//

import SwiftUI

public protocol CoordinatorProtocol: ObservableObject {
    associatedtype Route: Hashable

    var navigationPath: [Route] { get set }
    func push(route: Route)
    func pop()
}
