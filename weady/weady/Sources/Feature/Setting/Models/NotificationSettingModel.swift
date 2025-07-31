//
//  NotificationSettingModel.swift
//  weady
//
//  Created by 김영택 on 7/18/25.
//

import Foundation

/// 알림 유형과 UI 타이틀, 부가 설명을 정의하는 모델
enum NotificationType: CaseIterable, Codable, Hashable {
    case appPush
    case snowRain
    case daily
    case like
    case comment
    case scrap
    case personalInfoAgree

    var title: String {
        switch self {
        case .appPush: return "앱 푸시"
        case .snowRain: return "눈/비 알림"
        case .daily: return "하루 추천 알림"
        case .like: return "좋아요"
        case .comment: return "댓글"
        case .scrap: return "스크랩"
        case .personalInfoAgree: return "개인 정보 수집 및 이용 동의"
        }
    }

    var footerText: String? {
        switch self {
        case .snowRain:
            return "*비 소식이나 눈 예보가 있다면, 미리 알려드릴게요."
        default:
            return nil
        }
    }
}

/// 섹션별로 묶을 알림 유형 그룹
struct NotificationSection: Identifiable {
    let id = UUID()
    let title: String
    let types: [NotificationType]
}

/// 요일 선택용 모델
enum NotificationWeekday: Int, CaseIterable, Identifiable, Hashable, Codable {
    case monday = 1, tuesday, wednesday, thursday, friday, saturday, sunday
    var id: Int { rawValue }
    var title: String {
        switch self {
        case .monday:    return "월요일마다"
        case .tuesday:   return "화요일마다"
        case .wednesday: return "수요일마다"
        case .thursday:  return "목요일마다"
        case .friday:    return "금요일마다"
        case .saturday:  return "토요일마다"
        case .sunday:    return "일요일마다"
        }
    }
    var displayName: String { title.replacingOccurrences(of: "마다", with: "") }
}



