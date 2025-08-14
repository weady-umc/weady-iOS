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
    @State private var showDeleteAlert = false
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
                    iconName: "deleteicon",
                    title: "게시물 삭제하기",
                    titleColor: Color(UIColor.systemRed),
                    action: { showDeleteAlert = true }
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
        .alert("게시물을 삭제하시겠어요?", isPresented: $showDeleteAlert) {
            Button("취소", role: .cancel) {}
            Button("삭제", role: .destructive) {
                service.deleteBoard(boardId: boardId) { result in
                    switch result {
                    case .success:
                        onDeleteSuccess()
                    case .failure:
                        toast.showError("삭제에 실패했습니다. 잠시 후 다시 시도해주세요.")
                    }
                }
            }
        } message: {
            Text("삭제하면 되돌릴 수 없습니다.")
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
