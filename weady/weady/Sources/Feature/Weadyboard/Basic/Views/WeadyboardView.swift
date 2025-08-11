//
//  WeadyboardView.swift
//  weady
//
//  Created by 엄민서 on 7/10/25.
//

import SwiftUI
import Kingfisher

struct WeadyboardView: View {
    @Environment(WeadyboardRouter.self) private var router
    @State private var isFilterPresented = false
    @StateObject private var viewModel = WeadyboardViewModel()

    @State private var currentCriteria: BoardFilterCriteria = .init()

    private let cardWidth: CGFloat = 177

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
                    .padding(.trailing, 8)
                }
                .padding(.trailing, 8)
                .padding(.bottom, 6)

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
                        router.push(.weadyboardUpload)
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
                    .padding(.bottom, 86)
                    .padding(.trailing, 24)
                }
            }
        }
        .background(Color.white100)
        .sheet(isPresented: $isFilterPresented) {
            WeadyboardFilterSheet(
                onApply: { criteria in
                    currentCriteria = criteria
                    viewModel.applyFilter(criteria)
                },
                initialCriteria: currentCriteria
            )
        }
        .task {
            viewModel.fetchBoards()
        }
    }

    @ViewBuilder
    private func boardImageCard(item: BoardPreviewDTO) -> some View {
        let url = URL(string: item.imgUrl ?? "")
        let height = viewModel.heightFor(boardId: item.boardId, defaultHeight: 240)

        Button {
            router.push(.weadyboardPost(boardId: item.boardId))
        } label: {
            ZStack(alignment: .topTrailing) {
                KFImage(url)
                    .placeholder {
                        Color.gray100
                            .frame(width: cardWidth, height: height)
                            .cornerRadius(8)
                    }
                    .onSuccess { result in
                        viewModel.setHeight(
                            for: item.boardId,
                            imageSize: result.image.size,
                            targetWidth: cardWidth
                        )
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: cardWidth, height: height)
                    .clipped()
                    .cornerRadius(8)
                    .contentTransition(.opacity)
                    .transaction { tx in tx.animation = nil }

                Image(WeatherTag.imageName(for: item.weatherTagId))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .frame(width: 40, height: 40)
                    .background(Color.clear)
                    .padding(6)
            }
        }
        .buttonStyle(.plain)
    }
}
