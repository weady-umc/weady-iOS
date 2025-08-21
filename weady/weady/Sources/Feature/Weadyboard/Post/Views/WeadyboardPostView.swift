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
    @EnvironmentObject private var appState: AppState

    // 단일 바텀시트 컨테이너 상태
    @State private var sheetState: WeadyboardPostSheetState = .none
    @State private var showDim: Bool = false

    @State private var currentImageIndex: Int = 0
    
    // 편집 네비게이션
    @State private var goEdit = false
    @State private var editingPostSnapshot: BoardDetailResponseDTO? = nil
    
    init(boardId: Int, isTabBarHidden: Binding<Bool>) {
        self.boardId = boardId
        self._isTabBarHidden = isTabBarHidden
        _viewModel = StateObject(wrappedValue: WeadyboardPostViewModel(boardId: boardId))
        _reportVM = StateObject(wrappedValue: WeadyboardReportViewModel())
    }
    
    private var isMine: Bool {
        guard let post = viewModel.post else { return false }
        guard let myId = appState.currentUser?.id else { return false }
        return post.userId == myId
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
                            
                            WeadyboardPostImageView(
                                images: post.imageDtoList.map { $0.imgUrl },
                                currentIndex: $currentImageIndex
                            )
                            
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
                                    // 현재 보고 있는 이미지 URL 계산
                                    let urls = post.imageDtoList.map { $0.imgUrl }
                                    let preferred: String? = {
                                        guard !urls.isEmpty else { return nil }
                                        if currentImageIndex >= 0 && currentImageIndex < urls.count {
                                            return urls[currentImageIndex]
                                        } else {
                                            return urls.first
                                        }
                                    }()
                                    // 프론트 단독 방식: 로컬에 대표 이미지 저장 + 서버 스크랩 호출
                                    weadychiveVM.toggleBoardScrap(boardId: boardId, preferredImageUrl: preferred)
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
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    Group {
                        if isMine {
                            // 내 게시물: 수정/삭제 시트
                            BottomSheetContainer(
                                height: 255 * .deviceScale,
                                bottomPadding: 54 * .deviceScale,
                                onClose: { dismissSheet() }
                            ) {
                                WeadyboardMyPostMoreActionSheet(
                                    boardId: boardId,
                                    onEdit: {
                                        if let post = viewModel.post { editingPostSnapshot = post }
                                        dismissSheet()
                                        goEdit = true
                                    },
                                    onDeleteSuccess: {
                                        dismiss()
                                    }
                                )
                            }
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .zIndex(2)
                            .ignoresSafeArea(edges: .bottom)
                            
                        } else {
                            // 타인 게시물: 신고 시트
                            WeadyboardPostSheetContainer(
                                state: $sheetState,
                                boardId: boardId,
                                reportViewModel: reportVM,
                                onClose: { dismissSheet() }
                            )
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .zIndex(2)
                            .ignoresSafeArea(edges: .bottom)
                        }
                    }
                }
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
            // 댓글/대댓글 작성·삭제 시, 부모 화면의 댓글 수 즉시 반영
            WeadyboardPostCommentSheet(
                boardId: boardId,
                onCountChange: { delta in
                    guard delta != 0 else { return }
                    guard var post = viewModel.post else { return }
                    let newCount = max(0, (post.commentCount) + delta)
                    post.commentCount = newCount
                    viewModel.post = post
                }
            )
            .presentationDetents([.height(594 * .deviceScale)])
            .presentationDragIndicator(.visible)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        
        .navigationDestination(isPresented: $goEdit) {
            if let snapshot = editingPostSnapshot {
                UploadView(
                    mode: .edit(post: snapshot),
                    onSuccess: { viewModel.fetchPostDetail() }
                )
            } else {
                EmptyView()
            }
        }
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
}
