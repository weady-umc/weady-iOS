//
//  AppTabController.swift
//  weady
//
//  Created by 엄민서 on 8/10/25.
//

import SwiftUI
import Observation

// MARK: - AppTabController
/// 전역 탭 상태 컨트롤러 (어디서든 @Environment로 접근)

@Observable
final class AppTabController {
    // MARK: Properties
    var selected: TabType = .home
    // MARK: Methods
    func switchTo(_ tab: TabType) { selected = tab }
}
