//
//  WeadyboardPostView.swift
//  weady
//
//  Created by 엄민서 on 7/13/25.
//

import SwiftUI

struct WeadyboardPostView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var isTabBarHidden: Bool
    @State private var showCommentSheet = false
    @State private var showMoreSheet = false
    @State private var showReportSheet = false
    
    let boardId: Int
    @StateObject private var viewModel: WeadyboardPostViewModel
    @StateObject private var reportViewModel: WeadyboardReportViewModel

    @StateObject private var tagVM = TagViewModel()

    init(boardId: Int, isTabBarHidden: Binding<Bool>) {
        self.boardId = boardId
        self._isTabBarHidden = isTabBarHidden
        _viewModel = StateObject(wrappedValue: WeadyboardPostViewModel(boardId: boardId))
        _reportViewModel = StateObject(wrappedValue: WeadyboardReportViewModel())
    }

    var body: some View {
        VStack(spacing: 0) {
            CustomNavBar(
                viewTitle: "",
                showBackButton: true,
                backAction: {
                    isTabBarHidden = false
                    dismiss()
                }
            )
            
            if let post = viewModel.post {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        Spacer()
                        WeadyboardUserHeaderView(
                            userName: post.userName,
                            userProfileImageUrl: post.userProfileImageUrl ?? "profile",
                            onMoreTap: { showMoreSheet = true }
                        )
                        
                        WeadyboardPostImageView(images: post.imageDtoList.map { $0.imgUrl })
                        
                        WeadyboardActionButtonsView(
                            goodStatus: viewModel.post?.goodStatus ?? false,
                            goodCount: viewModel.post?.goodCount ?? 0,
                            commentCount: 0,
                            onLikeTap: {
                                if viewModel.post?.goodStatus == true {
                                    viewModel.unlikeBoard()
                                } else {
                                    viewModel.likeBoard()
                                }
                            },
                            onCommentTap: { showCommentSheet = true },
                            onBookmarkTap: { }
                        )
                        
                        WeadyboardContentView(
                            createdAt: post.createdAt,
                            content: post.content
                        )
                        
                        WeadyboardPostCardView(
                            userName: post.userName,
                            weatherText: weatherName(for: post.weatherTagId),
                            temperatureText: temperatureName(for: post.temperatureTagId),
                            placeDtoList: post.placeDtoList,
                            styleNames: post.styleIdList.compactMap { StyleTag(rawValue: $0)?.name }
                        )
                        .padding(.horizontal, 20)
                    }
                }
            } else if viewModel.isLoading {
                ProgressView().padding(.top, 100)
            } else if let error = viewModel.errorMessage {
                Text(error).foregroundColor(.red)
            }
        }
        .onAppear {
            isTabBarHidden = true
            viewModel.fetchPostDetail()
            tagVM.loadAll(initialCriteria: .init())
        }
        .onDisappear {
            isTabBarHidden = false
        }
        .sheet(isPresented: $showCommentSheet) {
            WeadyboardPostCommentSheet(boardId: boardId)
                .presentationDetents([.height(624)])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showMoreSheet) {
            WeadyboardPostMoreActionSheet(
                showReportSheet: $showReportSheet,
                boardId: boardId,
                reportViewModel: reportViewModel
            )
            .presentationDetents([.height(255)])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showReportSheet) {
            WeadyboardPostReportNavigationSheet(
                boardId: boardId,
                reportViewModel: reportViewModel
            )
            .presentationDetents([.height(759)])
            .presentationDragIndicator(.visible)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
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
        case 4: return "눈 오는 날"
        case 5: return "흐린 날"
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
