//
//  TabType.swift
//  weady
//
//  Created by 엄민서 on 7/10/25.
//

import SwiftUI

enum TabType: String, CaseIterable, Identifiable {
    case home, weadyboard, weadychive, mypage

    var id: String { rawValue }

    var imageName: String {
        switch self {
        case .home: return "home"
        case .weadyboard: return "weadyboard"
        case .weadychive: return "weadychive"
        case .mypage: return "profile"
        }
    }

    var selectedImageName: String {
        switch self {
        case .home: return "home_selected"
        case .weadyboard: return "weadyboard_selected"
        case .weadychive: return "weadychive_selected"
        case .mypage: return "profile_selected"
        }
    }
}
