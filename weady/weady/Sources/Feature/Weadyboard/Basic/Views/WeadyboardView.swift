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

    private var cardWidthScaled: CGFloat { 177 * .deviceScale }

    private var leftColumn: [BoardPreviewDTO] {
        viewModel.posts.enumerated().compactMap { $0.offset % 2 == 0 ? $0.element : nil }
    }
    private var rightColumn: [BoardPreviewDTO] {
        viewModel.posts.enumerated().compactMap { $0.offset % 2 == 1 ? $0.element : nil }
    }

    // 하단 여백 확보 코드
    private var bottomContentInset: CGFloat {
        (83 + 20) * .deviceScale
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                CustomNavBar(
                    viewTitle: "",
                    showLogoButton: true,
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
                            .frame(width: 18 * .deviceScale, height: 18 * .deviceScale)
                            .padding(6 * .deviceScale)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6 * .deviceScale)
                                    .stroke(Color.gray500)
                            )
                    }
                    .frame(width: 30 * .deviceScale, height: 30 * .deviceScale)
                    .padding(.trailing, 8 * .deviceScale)
                }
                .padding(.trailing, 8 * .deviceScale)
                .padding(.bottom, 5 * .deviceScale)
                
                ScrollView {
                    HStack(alignment: .top, spacing: 5 * .deviceScale) {
                        VStack(spacing: 5 * .deviceScale) {
                            ForEach(leftColumn, id: \.boardId) { item in
                                boardImageCard(item: item)
                            }
                        }
                        VStack(spacing: 5 * .deviceScale) {
                            ForEach(rightColumn, id: \.boardId) { item in
                                boardImageCard(item: item)
                            }
                        }
                    }
                    .padding(.horizontal, 5 * .deviceScale)
                    .padding(.top, 5 * .deviceScale)
                }
                // 하단 여백 확보 코드 
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: bottomContentInset)
                }
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        router.push(.weadyboardUpload)
                    }) {
                        HStack(spacing: 6 * .deviceScale) {
                            Image("plusicon")
                            Text("업로드")
                                .fontName(.bodySemibold16)
                                .foregroundStyle(Color.white100)
                        }
                        .padding(.horizontal, 14 * .deviceScale)
                        .padding(.vertical, 10 * .deviceScale)
                        .background(Color.black70)
                        .clipShape(RoundedRectangle(cornerRadius: 30 * .deviceScale))
                    }
                    .padding(.bottom, 64 * .deviceScale)
                    .padding(.trailing, 16 * .deviceScale)
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
        let defaultHeight = 240 * .deviceScale
        let height = viewModel.heightFor(boardId: item.boardId, defaultHeight: defaultHeight)

        Button {
            router.push(.weadyboardPost(boardId: item.boardId))
        } label: {
            ZStack(alignment: .topTrailing) {
                KFImage(url)
                    .placeholder {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white100)
                                .frame(width: cardWidthScaled, height: height)
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        }
                    }
                    .onSuccess { result in
                        viewModel.setHeight(
                            for: item.boardId,
                            imageSize: result.image.size,
                            targetWidth: cardWidthScaled
                        )
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: cardWidthScaled, height: height)
                    .clipped()
                    .cornerRadius(8)
                    .contentTransition(.opacity)
                    .transaction { tx in tx.animation = nil }

                Image(WeatherTag.imageName(for: item.weatherTagId))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 21 * .deviceScale, height: 21 * .deviceScale)
                    .frame(width: 40 * .deviceScale, height: 40 * .deviceScale)
                    .background(Color.clear)
                    .padding(5 * .deviceScale)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    WeadyboardView()
}
