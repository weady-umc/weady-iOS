//
//  NotificationViewModel.swift
//  weady
//
//  Created by 김영택 on 7/14/25.
//

import Foundation

@MainActor
class NotificationViewModel: ObservableObject {
    @Published var notifications: [NotificationItem] = []

    init() {
        loadNotifications()
    }
    
    func loadNotifications() {
        // 여기서는 예제용 더미 데이터
        notifications = [
            NotificationItem(id: UUID(), title: "오늘 비 소식이 있어요. 우산을 미리미리 준비하세요.", subtitle: nil, imageName: "notification1", time: Date().addingTimeInterval(0), isRead: true, showTime: false, highlightText: nil),
            NotificationItem(id: UUID(), title: "웨디의 하루 큐레이션이 도착했어요! 오늘 같이 맑은 날엔 가벼운 자켓 어때요?", subtitle: nil, imageName: "notification2", time: Date().addingTimeInterval(0), isRead: false, showTime: false, highlightText: nil),
            NotificationItem(id: UUID(), title: "닉네임님 외 423명이 회원님의 기록을 좋아합니다.", subtitle: "21시간 전", imageName: "notification3", time: Date().addingTimeInterval(-3600*21), isRead: false,showTime: true, highlightText: "닉네임"),
            NotificationItem(id: UUID(), title: "닉네임님이 회원님의 기록에 댓글을 남겼습니다.", subtitle: "19시간 전", imageName: "notification4", time: Date().addingTimeInterval(-3600*19), isRead: true, showTime: true, highlightText: "닉네임"),
            NotificationItem(id: UUID(), title: "닉네임님이 회원님의 기록을 스크랩했습니다.", subtitle: "2시간 전", imageName: "notification5", time: Date().addingTimeInterval(-3600*19), isRead: true, showTime: true, highlightText: "닉네임")
        ]
    }
    
    // 알림 삭제
    func deleteNotification(_ id: UUID) {
            notifications = notifications.filter { $0.id != id }
        }

    
    // 알림 읽음 처리
    func markAsRead(_ id: UUID) {
        if let index = notifications.firstIndex(where: { $0.id == id }) {
            notifications[index].isRead = true
        }
    }
}
