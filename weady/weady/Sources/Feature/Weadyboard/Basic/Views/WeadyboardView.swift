//
//  WeadyboardView.swift
//  weady
//
//  Created by 엄민서 on 7/10/25.
//

import SwiftUI

struct WeadyboardView: View {
    @Environment(NavigationRouter.self) private var router
    @State private var isFilterPresented = false
    @State private var selectedItem: WeadyBoardItem? = nil

    // 임의로 정해둔 게시물 별 날씨 아이콘
    private let boardItems: [WeadyBoardItem] = [
        .init(imageName: "boardex1", weather: "sunny"),
        .init(imageName: "boardex2", weather: "cloudy"),
        .init(imageName: "boardex3", weather: "rainy"),
        .init(imageName: "boardex4", weather: "partlycloudy"),
        .init(imageName: "boardex1", weather: "sunny"),
        .init(imageName: "boardex2", weather: "snowy"),
        .init(imageName: "boardex3", weather: "windy"),
        .init(imageName: "boardex4", weather: "cloudy")
    ]

    private var leftColumn: [WeadyBoardItem] {
        boardItems.enumerated().compactMap { $0.offset % 2 == 0 ? $0.element : nil }
    }

    private var rightColumn: [WeadyBoardItem] {
        boardItems.enumerated().compactMap { $0.offset % 2 == 1 ? $0.element : nil }
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
                            ForEach(leftColumn) { item in
                                boardImageCard(item: item)
                            }
                        }

                        VStack(spacing: 8) {
                            ForEach(rightColumn) { item in
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
    }

    @ViewBuilder
    private func boardImageCard(item: WeadyBoardItem) -> some View {
        Button {
            router.push(.weadyboardPostWithItem(item))
        } label: {
            ZStack(alignment: .topTrailing) {
                Image(item.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 177)
                    .clipped()
                    .cornerRadius(8)

                Image(item.weather)
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
