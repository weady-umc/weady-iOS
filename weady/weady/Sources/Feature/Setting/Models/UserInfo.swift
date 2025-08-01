//
//  UserInfo.swift
//  weady
//
//  Created by 김영택 on 7/18/25.
//

import Foundation

enum Gender: String, CaseIterable, Codable {
    case male
    case female
    case unspecified

    var label: String {
        switch self {
        case .male: return "남성"
        case .female: return "여성"
        case .unspecified: return "선택하지 않음"
        }
    }
}

struct UserInfo: Identifiable {
    var id: UUID = UUID()
    var email: String
    var name: String
    var phone: String
    var gender: Gender
    var isSocialLogin: Bool
}
