//
//  WeadyboardPostSheetContainer.swift
//  weady
//
//  Created by 엄민서 on 7/24/25.
//

import SwiftUI

struct WeadyboardPostSheetContainer: View {
    @Binding var state: WeadyboardPostSheetState

    let boardId: Int
    @ObservedObject var reportViewModel: WeadyboardReportViewModel
    var onClose: () -> Void

    // 고정 디자인 기준값
    private let moreHeight: CGFloat = 255 * .deviceScale
    private let reportHeight: CGFloat = 759 * .deviceScale

    // 핸들(캡슐) 스타일
    private let handleTopPadding: CGFloat = 18 * .deviceScale
    private let handleBottomPadding: CGFloat = 6 * .deviceScale

    // 드래그
    @State private var dragOffsetY: CGFloat = 0
    private let closeThreshold: CGFloat = 120 * .deviceScale

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    handleView

                    content
                }
                .frame(width: proxy.size.width, height: currentHeight)
                .background(Color.white100)
                .cornerRadius(10, corners: [.topLeft, .topRight])
                .offset(y: dragOffsetY)
                .gesture(
                    DragGesture(minimumDistance: 5)
                        .onChanged { value in
                            dragOffsetY = max(0, value.translation.height)
                        }
                        .onEnded { _ in
                            if dragOffsetY > closeThreshold {
                                onClose()
                                dragOffsetY = 0
                            } else {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                                    dragOffsetY = 0
                                }
                            }
                        }
                )
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
    }

    // MARK: - Handle (Capsule) 표시 제어
    @ViewBuilder
    private var handleView: some View {
        switch state {
        case .reportList, .reportDetail:
            Capsule()
                .frame(width: 36 * .deviceScale, height: 4 * .deviceScale)
                .opacity(0.2)
                .padding(.top, handleTopPadding)
                .padding(.bottom, handleBottomPadding)
        default:
            EmptyView()
        }
    }

    // MARK: - 콘텐츠
    @ViewBuilder
    private var content: some View {
        switch state {
        case .none:
            EmptyView()

        case .more:
            WeadyboardPostMoreActionSheet(
                boardId: boardId,
                reportViewModel: reportViewModel,
                onClose: onClose,
                onReportTap: {
                    withAnimation(.easeInOut) { state = .reportList }
                }
            )
            .frame(height: moreHeight)
            .padding(.bottom, 36 * .deviceScale)

        case .reportList:
            WeadyboardPostReportSheet(
                boardId: boardId,
                reportViewModel: reportViewModel,
                onBack: {
                    withAnimation(.easeInOut) { state = .more }
                },
                onClose: onClose,
                onNextDetail: { reason in
                    withAnimation(.easeInOut) { state = .reportDetail(reason) }
                },
                onSelect: { idx in
                    reportViewModel.selectedReasonIndex = idx
                }
            )
            .frame(height: reportHeight)

        case .reportDetail(let reason):
            WeadyboardPostReportDetailView(
                reason: reason,
                selectedReasonIndex: reportViewModel.selectedReasonIndex ?? 0,
                boardId: boardId,
                reportViewModel: reportViewModel,
                onBack: {
                    withAnimation(.easeInOut) { state = .reportList }
                },
                onClose: onClose
            )
            .frame(height: reportHeight)
        }
    }

    // MARK: - 높이
    private var currentHeight: CGFloat {
        switch state {
        case .more: return moreHeight
        case .reportList, .reportDetail: return reportHeight
        case .none: return 0
        }
    }
}
