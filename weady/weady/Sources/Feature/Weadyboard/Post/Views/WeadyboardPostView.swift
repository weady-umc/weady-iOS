//
//  WeadyboardPostView.swift
//  weady
//
//  Created by 엄민서 on 7/13/25.
//

import SwiftUI

// MARK: - 바텀시트 단계 상태
enum WeadyboardPostSheetState: Equatable {
    case none
    case more
    case reportList
    case reportDetail(ReportReason)
}

struct WeadyboardPostView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var isTabBarHidden: Bool
    @State private var showCommentSheet = false

    let boardId: Int
    @StateObject private var viewModel: WeadyboardPostViewModel
    @StateObject private var reportVM: WeadyboardReportViewModel
    @EnvironmentObject private var weadychiveVM: WeadychiveViewModel
    @StateObject private var tagVM = TagViewModel()

    // 단일 바텀시트 컨테이너 상태
    @State private var sheetState: WeadyboardPostSheetState = .none
    @State private var showDim: Bool = false

    init(boardId: Int, isTabBarHidden: Binding<Bool>) {
        self.boardId = boardId
        self._isTabBarHidden = isTabBarHidden
        _viewModel = StateObject(wrappedValue: WeadyboardPostViewModel(boardId: boardId))
        _reportVM = StateObject(wrappedValue: WeadyboardReportViewModel())
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                CustomNavBar(
                    viewTitle: "",
                    showBackButton: true,
                    showBottomDivider: false,
                    backAction: {
                        isTabBarHidden = false
                        dismiss()
                    }
                )
                
                if let post = viewModel.post {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16 * .deviceScale) {
                            
                            WeadyboardUserHeaderView(
                                userName: post.userName,
                                userProfileImageUrl: post.userProfileImageUrl,
                                onMoreTap: { present(.more) }
                            )
                            .padding(.bottom, -5 * .deviceScale)
                            
                            WeadyboardPostImageView(images: post.imageDtoList.map { $0.imgUrl })
                            
                            WeadyboardActionButtonsView(
                                goodStatus: viewModel.post?.goodStatus ?? false,
                                goodCount: viewModel.post?.goodCount ?? 0,
                                commentCount: viewModel.post?.commentCount ?? 0,
                                isScraped: weadychiveVM.isScrapped(boardId: boardId),
                                onLikeTap: {
                                    if viewModel.post?.goodStatus == true {
                                        viewModel.unlikeBoard()
                                    } else {
                                        viewModel.likeBoard()
                                    }
                                },
                                onCommentTap: { showCommentSheet = true },
                                onBookmarkTap: {
                                    weadychiveVM.toggleBoardScrap(boardId: boardId)
                                }
                            )
                            
                            WeadyboardContentView(
                                createdAt: post.createdAt,
                                content: post.content
                            )
                            
                            WeadyboardPostCardView(viewModel: viewModel)
                                .onAppear {
                                    viewModel.fetchPostDetail()
                                }
                            .padding(.horizontal, 20 * .deviceScale)
                        }
                    }
                } else if viewModel.isLoading {
                    ProgressView().padding(.top, 100 * .deviceScale)
                } else if let error = viewModel.errorMessage {
                    Text(error).foregroundColor(.red)
                }
            }
            
            // 단일 컨테이너 오버레이
            if sheetState != .none {
                Color.black.opacity(showDim ? 0.4 : 0.0)
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.2), value: showDim)
                    .onTapGesture { dismissSheet() }
                
                WeadyboardPostSheetContainer(
                    state: $sheetState,
                    boardId: boardId,
                    reportViewModel: reportVM,
                    onClose: { dismissSheet() }
                )
                .ignoresSafeArea(edges: .bottom)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(2)
            }
        }
        .onAppear {
            isTabBarHidden = true
            viewModel.fetchPostDetail()
            tagVM.loadAll(initialCriteria: .init())
            weadychiveVM.fetchScrappedBoards()
        }
        .onDisappear {
            isTabBarHidden = false
        }
        .sheet(isPresented: $showCommentSheet) {
            WeadyboardPostCommentSheet(boardId: boardId)
                .presentationDetents([.height(594 * .deviceScale)])
                .presentationDragIndicator(.visible)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }

    private func present(_ newState: WeadyboardPostSheetState) {
        sheetState = newState
        withAnimation(.easeInOut(duration: 0.2)) { showDim = true }
    }

    private func dismissSheet() {
        withAnimation(.easeInOut(duration: 0.2)) { showDim = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            sheetState = .none
        }
    }

    // MARK: - TagViewModel 사용
    private func weatherName(for id: Int?) -> String {
        guard let id else { return "" }
        if let name = tagVM.weathers.first(where: { $0.id == id })?.name {
            return name
        }
        switch id {
        case 1: return "맑은 날"
        case 2: return "구름 많은 날"
        case 3: return "비 오는 날"
        case 4: return "흐린 날"
        case 5: return "눈 오는 날"
        case 6: return "바람 많은 날"
        default: return ""
        }
    }

    private func temperatureName(for id: Int?) -> String {
        guard let id else { return "" }
        if let name = tagVM.temperatures.first(where: { $0.id == id })?.name {
            return name
        }
        switch id {
        case 1: return "~ -6℃"
        case 2: return "-5℃ ~ 5℃"
        case 3: return "6℃ ~ 11℃"
        case 4: return "12℃ ~ 16℃"
        case 5: return "17℃ ~ 22℃"
        case 6: return "23℃ ~ 26℃"
        case 7: return "27℃ ~ 30℃"
        case 8: return "31℃ ~"
        default: return ""
        }
    }
}
