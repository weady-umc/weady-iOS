//
//  WeadyboardFilterSheet.swift
//  weady
//
//  Created by 엄민서 on 7/24/25.
//

import SwiftUI

struct WeadyboardFilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(NavigationRouter.self) private var router
    
    @State private var selectedSeasons: Set<String> = []
    @State private var selectedWeathers: Set<String> = []
    @State private var temperature: Double = 10
    
    let seasonTags = ["봄", "여름", "가을", "겨울"]
    let weatherTags: [(label: String, iconName: String)] = [
        ("맑은 날", "sunny"),
        ("구름 많은 날", "cloudy"),
        ("비 오는 날", "rainy"),
        ("눈 오는 날", "snowy"),
        ("흐린 날", "partlycloudy"),
        ("바람 많은 날", "windy")
    ]
    
    var temperatureRangeText: String {
        let intTemp = Int(temperature)
        switch intTemp {
        case ..<(-5): return "-6℃"
        case -5...5:  return "-5℃ ~ 5℃"
        case 6...11:  return "6℃ ~ 11℃"
        case 12...16: return "12℃ ~ 16℃"
        case 17...22: return "17℃ ~ 22℃"
        case 23...26: return "23℃ ~ 26℃"
        case 27...30: return "27℃ ~ 30℃"
        default:      return "31℃"
        }
    }
    
    var temperatureStatusText: String {
        let intTemp = Int(temperature)
        switch intTemp {
        case ..<(-5): return "한파 수준의 날이에요"
        case -5...5:  return "매우 추운 날이에요"
        case 6...11:  return "쌀쌀한 날이에요"
        case 12...16: return "선선한 날이에요"
        case 17...22: return "따뜻한 날이에요"
        case 23...26: return "다소 더운 날이에요"
        case 27...30: return "더운 날이에요"
        default:      return "폭염 수준의 날이에요"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            CustomNavBar(
                viewTitle: "필터",
                showBackButton: true,
                showSubmitButton: true,
                showBottomDivider: false,
                backAction: {
                    router.pop()
                }
            )
            
            Spacer()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // 계절 필터
                    VStack(alignment: .leading, spacing: 12) {
                        Text("계절")
                            .fontName(.metaSemibold12)
                            .foregroundColor(.black100)
                            .padding(.leading, 10)
                        
                        Rectangle()
                            .fill(Color.gray600)
                            .frame(height: 1)
                        
                        HStack(spacing: 10) {
                            ForEach(seasonTags, id: \.self) { season in
                                FilterTag(
                                    text: season,
                                    isSelected: selectedSeasons.contains(season),
                                    selectedBackground: .black100,
                                    selectedTextColor: .white100,
                                    unselectedBackground: .white400,
                                    unselectedTextColor: .black100
                                ) {
                                    if selectedSeasons.contains(season) {
                                        selectedSeasons.remove(season)
                                    } else {
                                        selectedSeasons.insert(season)
                                    }
                                }
                            }
                        }
                    }
                    
                    // 기온 필터
                    VStack(alignment: .leading, spacing: 12) {
                        Text("기온")
                            .fontName(.metaSemibold12)
                            .foregroundColor(.black100)
                            .padding(.leading, 10)
                        
                        Rectangle()
                            .fill(Color.gray600)
                            .frame(height: 1)
                        
                        VStack(spacing: 2) {
                            Text(temperatureRangeText)
                                .fontName(.metaSemibold12)
                                .foregroundColor(.black100)
                            
                            Text(temperatureStatusText)
                                .fontName(.metaMedium10)
                                .foregroundColor(.black100)
                        }
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        
                        GradientSliderView(value: $temperature, range: -6...31)
                    }
                    
                    // 날씨 필터
                    VStack(alignment: .leading, spacing: 12) {
                        Text("날씨")
                            .fontName(.metaSemibold12)
                            .foregroundColor(.black100)
                            .padding(.leading, 10)
                        
                        Rectangle()
                            .fill(Color.gray600)
                            .frame(height: 1)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 15) {
                            ForEach(weatherTags, id: \.label) { tag in
                                FilterIconTag(
                                    label: tag.label,
                                    imageName: tag.iconName,
                                    isSelected: selectedWeathers.contains(tag.label),
                                    selectedBackground: .black100,
                                    selectedTextColor: .white100,
                                    unselectedBackground: .white400,
                                    unselectedTextColor: .black100
                                ) {
                                    if selectedWeathers.contains(tag.label) {
                                        selectedWeathers.remove(tag.label)
                                    } else {
                                        selectedWeathers.insert(tag.label)
                                    }
                                }
                                .frame(height: 26)
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
        .background(Color.white)
        .presentationDetents([.height(567)])
        .presentationDragIndicator(.hidden)
    }
}
