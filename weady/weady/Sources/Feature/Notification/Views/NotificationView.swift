//
//  NotificationView.swift
//  weady
//
//  Created by 김영택 on 7/14/25.
//
import SwiftUI

struct NotificationView: View {
    @StateObject private var viewModel = NotificationViewModel()
    
    var body: some View {
        if viewModel.notifications.isEmpty {
            EmptyNotificationView()
                .navigationTitle("알림")
        } else {
            List {
                ForEach(viewModel.notifications, id: \.id) { notification in
                    VStack(spacing: 0) {
                        NotificationRow(
                            notification: notification,
                            onDelete: {
                                viewModel.deleteNotification(notification.id)
                            },
                            onTap: {
                                viewModel.markAsRead(notification.id)
                            }
                        )
                        Divider()
                            .frame(height: 0.7)
                            .background(Color.gray600)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(notification.isRead ? Color.white : Color(UIColor.systemGray6))
                }
            }
            .listStyle(PlainListStyle())
            
            .navigationTitle("알림")
        }
    }
}


#Preview {
    NotificationView()
}

// 알림없는 화면
private struct EmptyNotificationView: View {
    var body: some View {
        VStack {
            Spacer()
            Image("bell")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.gray)
            Text("알림이 없습니다.")
                .foregroundColor(.black100)
                .font(AppTextStyle.bodyMedium16.font)
                .padding(.top, 10)
            Spacer()
        }
    }
}

// 알림 있는 화면
private struct NotificationRow: View {
    let notification: NotificationItem
    let onDelete: () -> Void
    let onTap: () -> Void

    var body: some View {
        let timeText = timeAgo(notification.time)//알림경과시간
        
        HStack(spacing: 12) {
            if let imageName = notification.imageName {
                Image(imageName)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            }
            // 프로필 사진
            
            VStack(alignment: .leading, spacing: 4) {
                formattedTitle
                
                if notification.showTime {
                    Text(timeText)
                        .font(AppTextStyle.metaRegular8.font)
                        .foregroundColor(.black100)
                }
            }
            
            Spacer()
            // 오른쪽 X 마크
            VStack(spacing: 4) {
                Button(action: onDelete) {
                    Image("xmark")
                        .resizable()
                        .frame(width: 25, height: 25)
                }
                .contentShape(Rectangle())
                
                // 읽음 -> 흰 배경, 안읽음 -> 회색배경
                Text(notification.isRead ? "읽음" : "안읽음")
                    .font(AppTextStyle.metaRegular8.font)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        // 왼쪽으로 스와이프시 삭제
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("삭제", systemImage: "trash")
            }
        }
    }

    // 알림 경과시간
    private func timeAgo(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    // 닉네임 부분 볼드체 강조
    private var formattedTitle: Text {
        guard let highlight = notification.highlightText,
              notification.title.contains(highlight)
        else {
            return Text(notification.title)
                .font(AppTextStyle.metaRegular12.font)
                .foregroundColor(.black100)
        }

        let parts = notification.title.components(separatedBy: highlight)

        return (
            Text(parts[0])
                .font(AppTextStyle.metaRegular12.font)
                .foregroundColor(.black100)
            + Text(highlight)
                .font(AppTextStyle.metaSemibold12.font)
                .foregroundColor(.black100)
            + Text(parts.count > 1 ? parts[1] : "")
                .font(AppTextStyle.metaRegular12.font)
                .foregroundColor(.black100)
        )
    }
}
