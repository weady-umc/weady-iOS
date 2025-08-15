//
//  WeadyboardPostCardView.swift
//  weady
//
//  Created by 엄민서 on 8/1/25.
//

import SwiftUI

struct WeadyboardPostCardView: View {
    @ObservedObject var viewModel: WeadyboardPostViewModel

    private func weatherIconName(for id: Int?) -> String {
        guard let id else { return "filter_sunny" }
        switch id {
        case 1: return "filter_sunny"        // 맑은 날
        case 2: return "filter_cloudy"       // 구름 많은 날
        case 3: return "filter_rainy"        // 비 오는 날
        case 4: return "filter_partlycloudy" // 흐린 날
        case 5: return "filter_snowy"        // 눈 오는 날
        case 6: return "filter_windy"        // 바람 많은 날
        default: return "filter_sunny"
        }
    }

    private func weatherText(for id: Int?) -> String {
        guard let id else { return "-" }
        switch id {
        case 1: return "맑은 날"
        case 2: return "구름 많은 날"
        case 3: return "비 오는 날"
        case 4: return "흐린 날"
        case 5: return "눈 오는 날"
        case 6: return "바람 많은 날"
        default: return "-"
        }
    }

    private func temperatureText(for id: Int?) -> String {
        guard let id else { return "-" }
        switch id {
        case 1: return "한파 수준"
        case 2: return "매우 추움"
        case 3: return "쌀쌀하다"
        case 4: return "선선하다"
        case 5: return "보통"
        case 6: return "약간 더움"
        case 7: return "더움"
        case 8: return "매우 더움"
        default: return "-"
        }
    }

    private func resolvedStyleNames(from dto: BoardDetailResponseDTO) -> [String] {

        return dto.styleIdList.map { "스타일 \($0)" }
    }

    var body: some View {
        Group {
            if let dto = viewModel.post {
                content(dto: dto)
            } else {
                placeholder
            }
        }
        .padding(.vertical, 16)
        .background(Color.white300)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func content(dto: BoardDetailResponseDTO) -> some View {
        let userName = dto.userName
        let weatherTextStr = weatherText(for: dto.weatherTagId)
        let temperatureTextStr = temperatureText(for: dto.temperatureTagId)
        let icon = weatherIconName(for: dto.weatherTagId)
        let places = dto.placeDtoList
        let styles = resolvedStyleNames(from: dto)

        return VStack(alignment: .leading, spacing: 12) {
            Text("웨디와 함께한 \(userName)님의 하루")
                .fontName(.metaMedium12)
                .foregroundColor(.appblack100)
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 12) {

                    // 날씨 박스
                    VStack(spacing: 6) {
                        Image(icon)
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text(weatherTextStr)
                            .fontName(.metaMedium12)
                            .foregroundColor(.appblack100)
                        Text(temperatureTextStr)
                            .fontName(.metaRegular10)
                            .foregroundColor(.appblack100)
                    }
                    .frame(width: 90, height: 110)
                    .background(Color.white100)
                    .cornerRadius(10)

                    // 장소 박스
                    if !places.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(Array(places.enumerated()), id: \.offset) { _, place in
                                HStack(spacing: 6) {
                                    Image(systemName: "mappin")
                                        .foregroundColor(.gray400)
                                    Text(place.placeName)
                                        .fontName(.metaMedium8)
                                        .foregroundColor(.appblack100)
                                }
                            }
                        }
                        .padding(12)
                        .background(Color.white100)
                        .cornerRadius(10)
                    }

                    // 스타일 박스
                    if !styles.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(styles, id: \.self) { style in
                                HStack(spacing: 6) {
                                    Image(systemName: "tag.fill")
                                        .foregroundColor(.gray400)
                                    Text(style)
                                        .fontName(.metaMedium8)
                                        .foregroundColor(.appblack100)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                        .padding(12)
                        .background(Color.white100)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 16)
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
