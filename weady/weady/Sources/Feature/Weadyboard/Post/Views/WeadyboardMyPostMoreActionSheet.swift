//
//  WeadyboardMyPostMoreActionSheet.swift
//  weady
//
//  Created by 엄민서 on 7/17/25.
//

import SwiftUI

struct WeadyboardMyPostMoreActionSheet: View {
    let boardId: Int
    let onEdit: () -> Void
    let onDeleteSuccess: () -> Void

    @EnvironmentObject private var toast: ToastCenter
    @State private var showDeleteModal = false
    private let service = BoardService()

    var body: some View {
        VStack(spacing: 0) {
            
            VStack(spacing: 0) {
                
                MyMoreActionButton(
                    iconName: "shareicon",
                    title: "게시물 공유하기",
                    action: {
                    }
                )

                MyMoreActionButton(
                    iconName: "updateicon",
                    title: "게시물 수정하기",
                    action: { onEdit() }
                )

                MyMoreActionButton(
                    iconName: "post_deleteicon",
                    title: "게시물 삭제하기",
                    titleColor: Color(UIColor.systemRed),
                    action: { withAnimation(.spring(response: 0.25, dampingFraction: 0.95)) { showDeleteModal = true } }
                )
            }
            .padding(.top, 24)
        }
        .frame(width: 375, height: 255)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white100)
                .cornerRadius(10, corners: [.topLeft, .topRight])
        )
        // 오버레이: 삭제 확인 모달
        if showDeleteModal {
            // 반투명 딤머
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeOut(duration: 0.18)) { showDeleteModal = false }
                }
            
            DeleteConfirmModal(
                title: "게시물을 삭제하시겠어요?",
                message: "삭제하시면 해당 기록은 완전히 사라지며, 이후에는 다시 확인하거나 복구할 수 없습니다.\n한 번 더 신중히 결정해 주세요.",
                confirmTitle: "삭제",
                cancelTitle: "취소",
                onConfirm: {
                    // 실제 삭제 요청
                    service.deleteBoard(boardId: boardId) { result in
                        switch result {
                        case .success:
                            withAnimation(.easeOut(duration: 0.18)) { showDeleteModal = false }
                            onDeleteSuccess()
                        case .failure:
                            withAnimation(.easeOut(duration: 0.18)) { showDeleteModal = false }
                            toast.showError("삭제에 실패했습니다. 잠시 후 다시 시도해주세요.")
                        }
                    }
                },
                onCancel: {
                    withAnimation(.easeOut(duration: 0.18)) { showDeleteModal = false }
                }
            )
            .transition(.scale.combined(with: .opacity))
            .zIndex(1)
        }
    }
}

// MARK: - 커스텀 삭제 확인 모달
private struct DeleteConfirmModal: View {
    let title: String
    let message: String
    let confirmTitle: String
    let cancelTitle: String
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // 본문
            VStack(spacing: 12) {
                Text(title)
                    .fontName(.bodySemibold16)
                    .foregroundColor(.black100)
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)

                Text(message)
                    .fontName(.captionRegular14)
                    .foregroundColor(.gray600)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
            }

            Divider().foregroundColor(.gray200)

            Button {
                onConfirm()
            } label: {
                Text(confirmTitle)
                    .fontName(.bodySemibold16)
                    .foregroundColor(Color(UIColor.systemRed))
                    .frame(maxWidth: .infinity, minHeight: 56)
            }

            Divider().foregroundColor(.gray200)

            Button {
                onCancel()
            } label: {
                Text(cancelTitle)
                    .fontName(.bodySemibold16)
                    .foregroundColor(.black100)
                    .frame(maxWidth: .infinity, minHeight: 56)
            }
        }
        .frame(width: 311)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white100)
                .shadow(color: .black.opacity(0.1), radius: 16, x: 0, y: 8)
        )
        .padding(.horizontal, 32)
    }
}

struct MyMoreActionButton: View {
    let iconName: String
    let title: String
    let titleColor: Color
    let action: () -> Void

    init(
        iconName: String,
        title: String,
        titleColor: Color = .black100,
        action: @escaping () -> Void
    ) {
        self.iconName = iconName
        self.title = title
        self.titleColor = titleColor
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(iconName)
                    .resizable()
                    .frame(width: 20, height: 20)

                Text(title)
                    .fontName(.captionRegular14)
                    .foregroundColor(titleColor)

                Spacer()
            }
            .padding(.horizontal, 24)
            .frame(height: 56)
        }
    }
}
