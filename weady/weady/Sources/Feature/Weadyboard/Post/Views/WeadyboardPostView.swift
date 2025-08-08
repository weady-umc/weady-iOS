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
    @StateObject private var viewModel = WeadyboardPostViewModel()
    @StateObject private var reportViewModel = WeadyboardReportViewModel()
    
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
                                guard let boardId = viewModel.post?.boardId else { return }
                                if viewModel.post?.goodStatus == true {
                                    viewModel.unlikeBoard(boardId: boardId)
                                } else {
                                    viewModel.likeBoard(boardId: boardId)
                                }
                            },
                            onCommentTap: {
                                showCommentSheet = true
                            },
                            onBookmarkTap: {
                            }
                        )
                        
                        WeadyboardContentView(
                            createdAt: post.createdAt,
                            content: post.content
                        )
                        
                        WeadyboardPostCardView(
                            userName: post.userName,
                            weatherText: viewModel.weatherLabel(for: post.weatherTagId),
                            temperatureText: viewModel.temperatureText(for: post.temperatureTagId),
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
            viewModel.fetchPostDetail(boardId: boardId)
        }
        .onDisappear {
            isTabBarHidden = false
        }
        .sheet(isPresented: $showCommentSheet) {
            WeadyboardPostCommentSheet(boardId: boardId)
                .presentationDetents([.height(624)])
        }
        .sheet(isPresented: $showMoreSheet) {
            WeadyboardPostMoreActionSheet(
                showReportSheet: $showReportSheet,
                boardId: boardId,
                reportViewModel: reportViewModel
            )
            .presentationDetents([.height(255)])
        }
        .sheet(isPresented: $showReportSheet) {
            WeadyboardPostReportNavigationSheet(
                boardId: boardId,
                reportViewModel: reportViewModel
            )
            .presentationDetents([.height(759)])
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}

