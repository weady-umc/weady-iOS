//
//  WeadyboardView.swift
//  weady
//
//  Created by 엄민서 on 7/10/25.
//

import SwiftUI
import Kingfisher

struct WeadyboardView: View {
    @Environment(NavigationRouter.self) private var router
    @State private var isFilterPresented = false
    @StateObject private var viewModel = WeadyboardViewModel()
    
    private var leftColumn: [BoardPreviewDTO] {
        viewModel.posts.enumerated().compactMap { $0.offset % 2 == 0 ? $0.element : nil }
    }
    
    private var rightColumn: [BoardPreviewDTO] {
        viewModel.posts.enumerated().compactMap { $0.offset % 2 == 1 ? $0.element : nil }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                CustomNavBar(
                    viewTitle: "",
                    showBackButton: false,
                    showAlarmButton: true,
                    showBottomDivider: false
                )
                
                HStack {
                    Spacer()
                    Button {
                        isFilterPresented = true
                    } label: {
                        Image("filtericon")
                            .resizable()
                            .frame(width: 14.63, height: 12.37)
                            .padding(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.gray500)
                            )
                    }
                    .frame(width: 30, height: 30)
                    .padding(.trailing, 20)
                    .padding(.bottom, 6)
                }
                
                ScrollView {
                    HStack(alignment: .top, spacing: 8) {
                        VStack(spacing: 8) {
                            ForEach(leftColumn, id: \.boardId) { item in
                                boardImageCard(item: item)
                            }
                        }
                        
                        VStack(spacing: 8) {
                            ForEach(rightColumn, id: \.boardId) { item in
                                boardImageCard(item: item)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        // 게시글 업로드 화면으로 이동
                    }) {
                        HStack(spacing: 6) {
                            Image("plusicon")
                            Text("업로드")
                                .fontName(.bodySemibold16)
                                .foregroundStyle(Color.white100)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.black70)
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                    }
                    .padding(.bottom, 106)
                    .padding(.trailing, 24)
                }
            }
        }
        .background(Color.white100)
        .sheet(isPresented: $isFilterPresented) {
            WeadyboardFilterSheet()
        }
                .task {
                    viewModel.fetchBoards()
                }
    }
    
    @ViewBuilder
    private func boardImageCard(item: BoardPreviewDTO) -> some View {
        Button {
            router.push(.weadyboardPostWithItem(item))
        } label: {
            ZStack(alignment: .topTrailing) {

                KFImage(URL(string: item.imgUrl ?? ""))
                    .placeholder {
                        Color.gray100
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: 177, height: 240)
                    .clipped()
                    .cornerRadius(8)
                
                Image(WeatherTag.imageName(for: item.weatherTagId))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .frame(width: 40, height: 40)
                    .background(Color.clear)
            }
        }
    }
}

#Preview {
    WeadyboardView()
}
