//
//  WeadyboardMyPostMoreActionSheet.swift
//  weady
//
//  Created by 엄민서 on 7/17/25.
//

import SwiftUI

struct WeadyboardMyPostMoreActionSheet: View {
    let boardId: Int
    @EnvironmentObject private var toast: ToastCenter
    private let service = BoardService()

    @State private var showDeleteConfirmAlert = false
    @State private var isDeleting = false
    @State private var showResultAlert = false
    @State private var resultTitle = ""
    @State private var resultMessage = ""

    let onEdit: () -> Void
    let onDeleteSuccess: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            
            VStack(spacing: 0) {
                
                MyMoreActionButton(
                    iconName: "shareicon",
                    title: "게시물 공유하기",
                    action: { }
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
                    action: {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.95)) {
                            showDeleteConfirmAlert = true
                        }
                    }
                )
            }
            .padding(.top, 24 * .deviceScale)
        }
     

        .alert("게시물을 삭제하시겠어요?", isPresented: $showDeleteConfirmAlert) {
            Button(isDeleting ? "삭제 중..." : "삭제", role: .destructive) {
                guard !isDeleting else { return }
                isDeleting = true
                service.deleteBoard(boardId: boardId) { result in
                    DispatchQueue.main.async {
                        isDeleting = false
                        switch result {
                        case .success:
                            resultTitle = "삭제 완료"
                            resultMessage = "게시물이 삭제되었습니다."
                            showResultAlert = true
                        case .failure:
                            resultTitle = "삭제 실패"
                            resultMessage = "삭제에 실패했습니다. 잠시 후 다시 시도해주세요."
                            showResultAlert = true
                        }
                    }
                }
            }
            .disabled(isDeleting)
            Button("취소", role: .cancel) { }
        } message: {
            Text("삭제하시면 해당 기록은 완전히 사라지며, 이후에는 다시 확인하거나 복구할 수 없습니다.\n한 번 더 신중히 결정해 주세요.")
        }
        .alert(resultTitle, isPresented: $showResultAlert) {
            Button("확인") {
                if resultTitle == "삭제 완료" { onDeleteSuccess() }
            }
        } message: {
            Text(resultMessage)
        }
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
            HStack(spacing: 12 * .deviceScale) {
                Image(iconName)
                    .resizable()
                    .frame(width: 20 * .deviceScale, height: 20 * .deviceScale)
                
                Text(title)
                    .fontName(.captionRegular14)
                    .foregroundColor(titleColor)

                Spacer()
            }
            .padding(.horizontal, 24 * .deviceScale)
            .frame(height: 56 * .deviceScale)
        }
    }
}
