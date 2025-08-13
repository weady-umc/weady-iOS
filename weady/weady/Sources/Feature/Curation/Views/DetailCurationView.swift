//
//  DetailCurationView.swift
//  weady
//
//  Created by 고석현 on 7/31/25.
//

import SwiftUI

/// 서버 연동 버전의 상세뷰
/// - 진입 파라미터: curationId (카드 탭 시 전달)
struct DetailCurationView: View {
    @Environment(\.dismiss) private var dismiss

    let curationId: Int64

    @StateObject private var vm = DetailCurationViewModel()
    @State private var currentIndex: Int = 0

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 25) {
                DetailCurationImageCarousel(currentIndex: $currentIndex,
                                            imageURLs: vm.detail?.imageURLs ?? [])

                DetailCurationMapButton()
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 100)

            if vm.isLoading {
                ProgressView().controlSize(.large)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(Color.white)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image("backicon")
                        .padding(.top, 50)
                        .padding(10)
                        .frame(width: 44, height: 44, alignment: .center)
                }
            }

            // NOTE: 요구 사항에 따라 line 49, 51의 Text를 모두 curationTitle로 표시
            ToolbarItem(placement: .principal) {
                VStack(spacing: 0) {
                    Text(vm.detail?.title ?? "")
                        .fontName(.captionMedium14)
                    Text(vm.detail?.title ?? "")
                        .fontName(.captionMedium14)
                }
                .padding(.top, 50)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { /* TODO: Scrap toggle logic */ }) {
                    Image("scrap")
                        .padding(.top, 50)
                }
            }
        }
        .task { await vm.load(curationId: curationId) }
    }
}

// MARK: - ViewModel
@MainActor
final class DetailCurationViewModel: ObservableObject {
    @Published var detail: CurationDetail? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    func load(curationId: Int64) async {
        isLoading = true
        errorMessage = nil
        await withCheckedContinuation { cont in
            CurationServices.shared.getCurationDetail(curationId: curationId) { [weak self] (result: Result<ApiResponseCurationByCurationIdResponseDto, CurationServices.APIError>) in
                guard let self = self else { cont.resume(); return }
                self.isLoading = false
                switch result {
                case .success(let dto):
                    // 서버 응답 → 도메인 매핑 (imgOrder 기준 정렬 포함)
                    self.detail = CurationMapper.toDetail(from: dto)
                case .failure(let error):
                    self.errorMessage = String(describing: error)
                }
                cont.resume()
            }
        }
    }
}

// MARK: - 이미지 캐러셀 (서버 URL 기반)
private struct DetailCurationImageCarousel: View {
    @Binding var currentIndex: Int
    let imageURLs: [URL]

    var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: $currentIndex) {
                ForEach(Array(imageURLs.enumerated()), id: \.offset) { index, url in
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Color.gray.opacity(0.15)
                                .frame(width: UIScreen.main.bounds.width, height: 600)
                                .clipped()
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: UIScreen.main.bounds.width, height: 600)
                                .clipped()
                        case .failure:
                            Color.gray.opacity(0.25)
                                .frame(width: UIScreen.main.bounds.width, height: 600)
                                .clipped()
                        @unknown default:
                            Color.gray.opacity(0.2)
                                .frame(width: UIScreen.main.bounds.width, height: 600)
                                .clipped()
                        }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(width: 350, height: 556)
            .cornerRadius(10)
            .ignoresSafeArea(.all, edges: .horizontal)

            IndicatorBarView(currentIndex: currentIndex, count: max(imageURLs.count, 1))
                .padding(.top, 16)
        }
    }
}

// MARK: - 네이버 지도 연결 버튼(기존 UI 유지)
private struct DetailCurationMapButton: View {
    var body: some View {
        Button(action: { /* TODO: - 네이버 지도로 연결 */ }) {
            Image("goToNaverMap")
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width - 32, height: 50)
        }
    }
}

// MARK: - 페이지 인디케이터 (기존 UI 유지)
private struct IndicatorBarView: View {
    let currentIndex: Int
    let count: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { index in
                if index == currentIndex {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: 20, height: 6)
                        .foregroundColor(.white)
                } else {
                    Circle()
                        .frame(width: 6, height: 6)
                        .foregroundColor(.white)
                }
            }
        }
    }
}

#Preview {
    DetailCurationView(curationId: 1)
}
