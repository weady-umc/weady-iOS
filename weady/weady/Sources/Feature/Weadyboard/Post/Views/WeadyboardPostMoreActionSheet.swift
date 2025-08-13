//
//  WeadyboardPostMoreActionSheet.swift
//  weady
//
//  Created by 엄민서 on 7/17/25.
//

import SwiftUI

struct WeadyboardPostMoreActionSheet: View {
    @Binding var showReportSheet: Bool
    let boardId: Int
    @ObservedObject var reportViewModel: WeadyboardReportViewModel
    @EnvironmentObject private var toast: ToastCenter

    var body: some View {
        VStack(spacing: 0) {
            
            VStack(spacing: 0) {
                MoreActionButton(
                    iconName: "shareicon",
                    title: "게시물 공유하기",
                    action: {
                    })

                MoreActionButton(
                    iconName: "hideicon",
                    title: "게시물 숨기기",
                    action: {
                        reportViewModel.hide(boardId: boardId) { result in
                            switch result {
                            case .success:
                                toast.showSuccess("게시물이 숨겨졌습니다.")
                            case .failure:
                                toast.showError("숨기기에 실패했습니다. 잠시 후 다시 시도해주세요.")
                            }
                        }
                    })

                MoreActionButton(
                    iconName: "reporticon",
                    title: "게시물 신고하기",
                    titleColor: Color(UIColor.systemRed), 
                    action: {
                        showReportSheet = true
                    })
            }
            .padding(.top, 24)
        }
        .frame(width: 375, height: 255)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white100)
                .cornerRadius(10, corners: [.topLeft, .topRight])
        )
    }
}

struct MoreActionButton: View {
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
