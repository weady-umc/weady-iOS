//
//  WeadyboardPostCardView.swift
//  weady
//
//  Created by 엄민서 on 8/1/25.
//

import SwiftUI

struct WeadyboardPostCardView: View {
    let userName: String
    let weatherText: String
    let temperatureText: String
    let placeDtoList: [PlaceDTO]
    let styleNames: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("웨디와 함께한 \(userName)님의 하루")
                .fontName(.metaMedium12)
                .foregroundColor(.appblack100)
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 12) {
                    
                    // 날씨 박스
                    VStack(spacing: 6) {
                        Image("partlycloudy") // TODO: weatherTagId → 이미지 매핑
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text(weatherText)
                            .fontName(.metaMedium12)
                            .foregroundColor(.appblack100)
                        Text(temperatureText)
                            .fontName(.metaRegular10)
                            .foregroundColor(.appblack100)
                    }
                    .frame(width: 90, height: 110)
                    .cornerRadius(10)

                    // 장소 박스
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(placeDtoList, id: \.placeName) { place in
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

                    // 스타일 박스
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(styleNames, id: \.self) { style in
                            HStack(spacing: 6) {
                                Image(systemName: "tag.fill")
                                    .foregroundColor(.gray400)
                                Text("\(style) | 상품명 어쩌고 저쩌고")
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
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 16)
        .background(Color.white300)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
