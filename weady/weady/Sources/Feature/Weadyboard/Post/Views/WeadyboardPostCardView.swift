//
//  WeadyboardPostCardView.swift
//  weady
//
//  Created by 엄민서 on 8/1/25.
//

import SwiftUI

struct WeadyboardPostCardView: View {
    @ObservedObject var viewModel: WeadyboardPostViewModel

    // 의류 스타일 카테고리(id -> name) 매핑 저장
    @State private var styleMap: [Int: String] = [:]
    @State private var isLoadingStyleMap: Bool = false
    @State private var styleMapError: String?

    private let tagService: TagServiceProtocol

    init(viewModel: WeadyboardPostViewModel, tagService: TagServiceProtocol = TagService()) {
        self.viewModel = viewModel
        self.tagService = tagService
    }

    // MARK: - Weather Mappers
    private func weatherIcon(for id: Int?) -> (name: String, size: CGSize) {
        guard let id else { return ("filter_sunny", CGSize(width: 27 * .deviceScale, height: 27 * .deviceScale)) }
        switch id {
        case 1: return ("boardcard_sunny", CGSize(width: 24 * .deviceScale, height: 24 * .deviceScale))        // 맑은 날
        case 2: return ("filter_cloudy", CGSize(width: 24 * .deviceScale, height: 16 * .deviceScale))       // 구름 많은 날
        case 3: return ("filter_rainy", CGSize(width: 25 * .deviceScale, height: 26 * .deviceScale))        // 비 오는 날
        case 4: return ("filter_partlycloudy", CGSize(width: 31 * .deviceScale, height: 22 * .deviceScale)) // 흐린 날
        case 5: return ("filter_snowy", CGSize(width: 26 * .deviceScale, height: 26 * .deviceScale))           // 눈 오는 날
        case 6: return ("filter_windy", CGSize(width: 28 * .deviceScale, height: 22 * .deviceScale))        // 바람 많은 날
        default: return ("boardcard_sunny", CGSize(width: 24 * .deviceScale, height: 24 * .deviceScale))
        }
    }

    private func weatherText(for id: Int?) -> String {
        guard let id else { return "-" }
        switch id {
        case 1: return "맑음"
        case 2: return "구름 많음"
        case 3: return "비 오는 날"
        case 4: return "흐린날"
        case 5: return "눈 오는 날"
        case 6: return "바람 많은 날"
        default: return "-"
        }
    }

    private func temperatureText(for id: Int?) -> String {
        guard let id else { return "-" }
        switch id {
        case 1: return "~ -6℃"
        case 2: return "-5℃ ~ 5℃"
        case 3: return "6℃ ~ 11℃"
        case 4: return "12℃ ~ 16℃"
        case 5: return "17℃ ~ 22℃"
        case 6: return "23℃ ~ 26℃"
        case 7: return "27℃ ~ 30℃"
        case 8: return "31℃ ~"
        default: return "-"
        }
    }

    private func resolvedStyleNames(from dto: BoardDetailResponseDTO) -> [String] {
        return dto.styleIdList.map { id in
            if let name = styleMap[id] {
                return name
            } else {
                return "스타일 \(id)"
            }
        }
    }

    private func ensureStyleMapLoaded() {
        guard styleMap.isEmpty, !isLoadingStyleMap else { return }
        isLoadingStyleMap = true
        styleMapError = nil

        tagService.getClothesStyleCategories { result in
            DispatchQueue.main.async {
                self.isLoadingStyleMap = false
                switch result {
                case .success(let categories):
                    var map: [Int: String] = [:]
                    for item in categories {
                        map[Int(item.id)] = item.name
                    }
                    self.styleMap = map
                case .failure(let error):
                    self.styleMapError = error.localizedDescription
                }
            }
        }
    }

    var body: some View {
        Group {
            if let dto = viewModel.post {
                content(dto: dto)
            } else {
                placeholder
            }
        }
        .onAppear { ensureStyleMapLoaded() }
        .padding(.vertical, 16 * .deviceScale)
        .background(Color.white300)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func content(dto: BoardDetailResponseDTO) -> some View {
        let userName = dto.userName
        let weatherTextStr = weatherText(for: dto.weatherTagId)
        let temperatureTextStr = temperatureText(for: dto.temperatureTagId)
        let icon = weatherIcon(for: dto.weatherTagId)
        let places = dto.placeDtoList
        let styles = resolvedStyleNames(from: dto)

        return VStack(alignment: .leading, spacing: 12 * .deviceScale) {
            Text("웨디와 함께한 \(userName)님의 하루")
                .fontName(.metaMedium12)
                .foregroundColor(.appblack100)
                .padding(.horizontal, 16 * .deviceScale)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 12 * .deviceScale) {
                    
                    // MARK: - 날씨 박스
                    VStack(spacing: 6 * .deviceScale) {
                        Image(icon.name)
                            .resizable()
                            .frame(width: icon.size.width, height: icon.size.height)
                            .shadow(color: .black.opacity(0.07), radius: 10, x: 0, y: 4)
                        Text(weatherTextStr)
                            .fontName(.metaRegular12)
                            .foregroundColor(.appblack100)
                        Text(temperatureTextStr)
                            .fontName(.metaRegular10)
                            .foregroundColor(.appblack100)
                    }
                    .padding(.horizontal, 15 * .deviceScale)
                    .padding(.top, 12 * .deviceScale)
                    
                    // MARK: - 장소 박스
                    if !places.isEmpty {
                        VStack(alignment: .leading, spacing: 8 * .deviceScale) {
                            ForEach(Array(places.enumerated()), id: \.offset) { _, place in
                                HStack(spacing: 4 * .deviceScale) {
                                    Image("placeicon")
                                        .resizable()
                                        .frame(width: 8.75 * .deviceScale, height: 12.5 * .deviceScale)
                                        .frame(width: 15 * .deviceScale, height: 15 * .deviceScale)
                                    Text(place.placeName)
                                        .fontName(.metaMedium8)
                                        .foregroundColor(.appblack100)
                                }
                            }
                        }
                        // 가로 길이 길게 고정으로 하고싶은 경우
//                        .frame(width: 115 * .deviceScale, height: 85 * .deviceScale)
                        .frame(height: 85 * .deviceScale)
                        .padding(.horizontal, 14.5 * .deviceScale)
                        .background(Color.white100)
                        .cornerRadius(10)
                    } else {
                        // UPDATED: 장소 없을 때 기본 아이콘 + 문구
                        HStack(spacing: 4 * .deviceScale) {
                            Image("placeicon")
                                .resizable()
                                .frame(width: 8.75 * .deviceScale, height: 12.5 * .deviceScale)
                                .frame(width: 15 * .deviceScale, height: 15 * .deviceScale)
                            Text("아직 등록된 장소가 없어요")
                                .fontName(.metaMedium8)
                                .foregroundColor(.appblack100)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(height: 85 * .deviceScale)
                        .padding(.horizontal, 14.5 * .deviceScale)
                        .background(Color.white100)
                        .cornerRadius(10)
                    }
                    
                    // MARK: - 스타일 박스
                    if !styles.isEmpty {
                        VStack(alignment: .leading, spacing: 8 * .deviceScale) {
                            ForEach(styles, id: \.self) { style in
                                HStack(spacing: 4 * .deviceScale) {
                                    Image("brandicon")
                                        .resizable()
                                        .frame(width: 12.81 * .deviceScale, height: 12.81 * .deviceScale)
                                        .frame(width: 15 * .deviceScale, height: 15 * .deviceScale)
                                    Text(style)
                                        .fontName(.metaMedium8)
                                        .foregroundColor(.appblack100)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                        // 가로 길이 길게 고정으로 하고싶은 경우
//                        .frame(width: 125 * .deviceScale, height: 85 * .deviceScale)
                        .frame(height: 85 * .deviceScale)
                        .padding(.horizontal, 14.5 * .deviceScale)
                        .background(Color.white100)
                        .cornerRadius(10)
                    } else {
                        // UPDATED: 스타일 없을 때 기본 아이콘 + 문구
                        HStack(spacing: 4 * .deviceScale) {
                            Image("brandicon")
                                .resizable()
                                .frame(width: 12.81 * .deviceScale, height: 12.81 * .deviceScale)
                                .frame(width: 15 * .deviceScale, height: 15 * .deviceScale)
                            Text("아직 등록된 옷 정보가 없어요")
                                .fontName(.metaMedium8)
                                .foregroundColor(.appblack100)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(height: 85 * .deviceScale)
                        .padding(.horizontal, 14.5 * .deviceScale)
                        .background(Color.white100)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 16 * .deviceScale)
            }
        }
    }

    private var placeholder: some View {
        VStack(alignment: .leading, spacing: 12) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white200)
                .frame(width: 160, height: 12)
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white200)
                        .frame(width: 90, height: 110)
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white200)
                        .frame(width: 160, height: 110)
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white200)
                        .frame(width: 160, height: 110)
                }
                .padding(.horizontal, 16)
            }
        }
        .redacted(reason: viewModel.isLoading ? .placeholder : [])
    }
}
