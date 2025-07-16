//
//  NotificationItem.swift
//  weady
//
//  Created by 김영택 on 7/14/25.
//

import Foundation

struct NotificationItem: Identifiable, Codable {
    let id: UUID = UUID()
    let title: String //닉네임
    let subtitle: String? //몇시간 전
    let imageName: String? // 알림 썸네일 아이콘
    let time: Date //시간
    var isRead: Bool //읽음 안읽음
    let showTime: Bool //몇시간전 유무
    let highlightText: String? //닉네임 강조할 부분
}
