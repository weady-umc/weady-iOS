//
//  WeadyboardRouteBridge.swift
//  weady
//
//  Created by 엄민서 on 8/10/25.
//

import SwiftUI
import Observation

// MARK: - WeadyboardRouteBridge
/// 다른 탭에서 보드 플로우로 연결
@Observable
final class WeadyboardRouteBridge {
    // MARK: Properties
    var handler: ((WeadyboardRoute) -> Void)?
    // MARK: Methods
    func navigate(_ route: WeadyboardRoute) { handler?(route) }
}
