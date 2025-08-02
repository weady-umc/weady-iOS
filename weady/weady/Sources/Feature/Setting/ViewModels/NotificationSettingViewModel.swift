//
//  NotificationSettingViewModel.swift
//  weady
//
//  Created by 김영택 on 7/18/25.
//

import SwiftUI

@MainActor
class NotificationSettingViewModel: ObservableObject {
    // MARK: - 기존 토글 상태
    @Published private var settings: [NotificationType: Bool]

    // MARK: - 눈/비 알림 추가 설정
    /// 시간
    @Published var snowRainTime: Date
    /// 선택된 요일들
    @Published var snowRainSelectedWeekdays: Set<NotificationWeekday>
    
    // MARK: - 하루 추천 알림 추가 설정
    @Published var dailyTime: Date
    @Published var dailySelectedWeekdays: Set<NotificationWeekday>

    init() {
        // 기본 토글 상태
        self.settings = [
            .appPush: true,
            .snowRain: false,
            .daily: false,
            .like: true,
            .comment: true,
            .scrap: true,
            .personalInfoAgree: true
        ]
        
        // (a)눈 비 알림 기본 시간:  오전 7시
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        comps.hour = 7
        comps.minute = 0
        self.snowRainTime = Calendar.current.date(from: comps) ?? Date()
        
        // (b) 기본 조건: 매일
        self.snowRainSelectedWeekdays = Set(NotificationWeekday.allCases)
        
        // (c) 하루 추천 알림 기본 시간: 오전 9시
        var dailyComps = Calendar.current.dateComponents([.year, .month, .day], from: .now)
        dailyComps.hour = 9
        dailyComps.minute = 0
        self.dailyTime = Calendar.current.date(from: dailyComps)!
        
        // (d) 하루 추천 알림 기본 조건: 매일
        self.dailySelectedWeekdays = Set(NotificationWeekday.allCases)
    }
    

    /// NotificationType 토글 바인딩
    func binding(for type: NotificationType) -> Binding<Bool> {
        Binding(
            get: { self.settings[type, default: false] },
            set: { self.settings[type] = $0 }
        )
    }

    /// 저장 (API 연동 자리)
    func saveSettings() {
        print("알림 설정 저장:", settings)
        // TODO: 서버에 settings, snowRainTime, snowRainSelectedWeekdays 전송
    }

    // MARK: - 눈/비 알림 화면에 표시할 텍스트

    /// "오전 07:00" 형식
    var snowRainTimeText: String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "ko_KR")
        fmt.dateFormat = "a hh:mm"
        return fmt.string(from: snowRainTime)
    }

    /// 선택된 요일에 따라 "매일" 또는 "수요일, 목요일" 형식
    var snowRainConditionText: String {
        if snowRainSelectedWeekdays.count == NotificationWeekday.allCases.count {
            return "매일"
        }
        // RawValue 순서 기준으로 정렬
        let ordered = NotificationWeekday.allCases.sorted(by: { $0.rawValue < $1.rawValue })
        let names = ordered
            .filter { snowRainSelectedWeekdays.contains($0) }
            .map { $0.displayName }
        return names.joined(separator: ", ")
    }
    
    // MARK: - 하루 추천 알림 화면에 표시할 텍스트
    var dailyTimeText: String {
            let fmt = DateFormatter()
            fmt.locale = Locale(identifier: "ko_KR")
            fmt.dateFormat = "a hh:mm"
            return fmt.string(from: dailyTime)
        }

    var dailyConditionText: String {
        let all = NotificationWeekday.allCases
        if dailySelectedWeekdays.count == all.count { return "매일" }
        return all
            .sorted(by: { $0.rawValue < $1.rawValue })
            .filter { dailySelectedWeekdays.contains($0) }
            .map(\.displayName)
            .joined(separator: ", ")
    }
}
