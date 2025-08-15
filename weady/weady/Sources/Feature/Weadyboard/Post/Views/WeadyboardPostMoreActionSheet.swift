//
//  WeadyboardPostMoreActionSheet.swift
//  weady
//
//  Created by 엄민서 on 7/17/25.
//

import SwiftUI

struct WeadyboardPostMoreActionSheet: View {
    let boardId: Int
    @ObservedObject var reportViewModel: WeadyboardReportViewModel
    @EnvironmentObject private var toast: ToastCenter

    @State private var showUnhideBanner: Bool = false
    @State private var unhideDismissWorkItem: DispatchWorkItem?

    var onClose: () -> Void
    var onReportTap: () -> Void

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
                                presentUndoBanner()
                            case .failure:
                                toast.showError("숨기기에 실패했습니다. 잠시 후 다시 시도해주세요.")
                            }
                        }
                    }
                )

                MoreActionButton(
                    iconName: "reporticon",
                    title: "게시물 신고하기",
                    titleColor: Color(UIColor.systemRed), 
                    action: {
                        reportViewModel.selectedReasonIndex = nil
                        onReportTap()
                    }
                )
            }
            .padding(.top, 24)
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white100)
                .cornerRadius(10, corners: [.topLeft, .topRight])
        )
        .overlay(alignment: .bottom) {
            if showUnhideBanner {
                UndoHideBanner(
                    onUndo: {
                        unhideDismissWorkItem?.cancel()
                        reportViewModel.unhide(boardId: boardId) { result in
                            switch result {
                            case .success:
                                toast.showSuccess("숨기기가 취소되었습니다.")
                                withAnimation(.easeInOut) {
                                    showUnhideBanner = false
                                }
                            case .failure:
                                toast.showError("숨기기 취소에 실패했습니다. 잠시 후 다시 시도해주세요.")
                            }
                        }
                    },
                    onTimeout: {
                        withAnimation(.easeInOut) {
                            showUnhideBanner = false
                        }
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .padding(.bottom, 12)
            }
        }
    }
    
    private func presentUndoBanner() {
        unhideDismissWorkItem?.cancel()
        
        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
            showUnhideBanner = true
        }
        
        let work = DispatchWorkItem {
            withAnimation(.easeInOut) {
                showUnhideBanner = false
            }
        }
        unhideDismissWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: work) // 3초 뒤 자동 닫힘
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

// 하단 UndoHide 배너 컴포넌트
private struct UndoHideBanner: View {
    let onUndo: () -> Void
    let onTimeout: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text("게시물이 숨겨졌습니다.")
                .fontName(.captionRegular14)
                .foregroundStyle(.appwhite100)

            Spacer()

            Button(action: onUndo) {
                Text("숨기기 취소")
                    .fontName(.captionSemibold14)
                    .foregroundStyle(.appwhite100)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.15))
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.9))
        )
        .padding(.horizontal, 16)
    }
}
