//
//  WeadyboardPostView.swift
//  weady
//
//  Created by 엄민서 on 7/13/25.
//

import SwiftUI

// TODO: 게시물 화면 아직 수정중
struct WeadyboardPostView: View {
    @Environment(NavigationRouter.self) private var router
    @Binding var isTabBarHidden: Bool
    @State private var showCommentSheet = false
    @State private var selectedPage = 0
    @State private var showMoreSheet = false
    @State private var showReportSheet = false
    @State private var selectedReason: ReportReason? = nil
    let item: WeadyBoardItem
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavBar(
                viewTitle: "",
                showBackButton: true,
                backAction: {
                    isTabBarHidden = false
                    router.pop()
                }
            )
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    TabView {
                        Image(item.imageName)
                            .resizable()
                            .frame(width: 375, height: 470)
                            .clipped()
                    }
                    .frame(width: 375, height: 470)
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                    .cornerRadius(12)
                    
                    HStack(spacing: 24) {
                        Image("likes")
                        Text("138").fontName(.metaRegular12)
                        Button { showCommentSheet = true } label: {
                            Image("comment")
                        }
                        Text("7").fontName(.metaRegular12)
                        Image("bookmark")
                        Button { showMoreSheet = true } label: {
                            Image("more")
                        }
                    }
                    .font(.system(size: 20))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    
                    Text("어쩌구 저쩌구 내용 텍스트")
                        .fontName(.captionRegular14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                }
            }
        }
        .onAppear {
            isTabBarHidden = true
        }
        .onDisappear {
            isTabBarHidden = false
        }
        .sheet(isPresented: $showCommentSheet) {
            CommentBottomSheet()
                .presentationDetents([.height(624)])
        }
        .sheet(isPresented: $showMoreSheet) {
            PostMoreActionSheet(showReportSheet: $showReportSheet)
                .presentationDetents([.height(255)])
        }
        .sheet(isPresented: $showReportSheet) {
            WeadyboardPostReportNavigationSheet()
                .presentationDetents([.height(759)])
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}
