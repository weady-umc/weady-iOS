//
//  CurationModel.swift
//  weady
//
//  Created by 고석현 on 8/12/25.
//

import Foundation
import SwiftUI

// MARK: - 계절태그,날씨태그 -> 날씨 문구 + 컬러칩 달라짐
enum Season: String, CaseIterable, Codable {
    case spring = "봄"
    case summer = "여름"
    case autumn = "가을"
    case winter = "겨울"
    case unknown

    init(server: String) {
        self = Season(rawValue: server) ?? .unknown
    }
}

enum SkyWeather: String, CaseIterable, Codable {
    case clear = "맑은날"
    case mostlyCloudy = "구름 많은 날"
    case cloudy = "흐린 날"
    case rainy = "비 오는 날"
    case windy = "바람 많은 날"
    case snowy = "눈 오는 날"
    case unknown

    init(server: String) {
        self = SkyWeather(rawValue: server) ?? .unknown
    }
}

// MARK: - 컬러칩(날씨 문구 + 장소 칩 테두리 색상)

enum SemanticColor: String, Codable, CaseIterable {
    case springClear
    case springCloudy
    case springRainy
    case summerClear
    case summerCloudy
    case summerRainy
    case autumnClear
    case autumnCloudy
    case autumnRainy
    case winterClear
    case winterCloudy
    case winterRainy
    
    var color: Color {
        switch self {
        case .springClear: return Color("springClear")
        case .springCloudy: return Color("springCloudy")
        case .springRainy: return Color("springRainy")
        case .summerClear: return Color("summerClear")
        case .summerCloudy: return Color("summerCloudy")
        case .summerRainy: return Color("summerRainy")
        case .autumnClear: return Color("autumnClear")
        case .autumnCloudy: return Color("autumnCloudy")
        case .autumnRainy: return Color("autumnRainy")
        case .winterClear: return Color("winterClear")
        case .winterCloudy: return Color("winterCloudy")
        case .winterRainy: return Color("winterRainy")
        }
    }
}

/// 계절+날씨 조합에 따른 컬러칩
enum WeatherTone {
    static func tone(for season: Season, weather: SkyWeather) -> SemanticColor {
        switch (season, weather) {
        case (.spring, .clear):
            return .springClear
        case (.spring, .mostlyCloudy), (.spring, .cloudy):
            return .springCloudy
        case (.spring, .rainy):
            return .springRainy
        case (.summer, .clear):
            return .summerClear
        case (.summer, .mostlyCloudy), (.summer, .cloudy):
            return .summerCloudy
        case (.summer, .rainy):
            return .summerRainy
        case (.autumn, .clear):
            return .autumnClear
        case (.autumn, .mostlyCloudy), (.autumn, .cloudy):
            return .autumnCloudy
        case (.autumn, .rainy):
            return .autumnRainy
        case (.winter, .clear):
            return .winterClear
        case (.winter, .mostlyCloudy), (.winter, .cloudy):
            return .winterCloudy
        case (.winter, .rainy):
            return .winterRainy
        case (.winter, .snowy):
            return .winterCloudy
        default:
            return .springClear
        }
    }
}

// MARK: - Header Phrase
/// 상단 문구: [가변] + [고정] 구조
struct WeatherHeaderText: Equatable {
    /// ex) "맑고 따듯한 봄날"
    let leading: String
    /// 고정 텍스트
    let trailing: String = "에는 이런 코스들을 추천해드려요"
}

enum WeatherPhrase {
    /// 서버에서 받은 시즌/날씨 조합 → 상단 가변 문구
    static func leading(season: Season, weather: SkyWeather) -> String {
        switch (season, weather) {
        case (.spring, .clear):          return "맑고 따듯한 봄날"
        case (.spring, .mostlyCloudy):   return "구름이 머무는 봄날"
        case (.spring, .cloudy):         return "구름낀 흐린 봄날"
        case (.spring, .rainy):          return "추적추적 비가 내리는 봄날"
        case (.spring, .windy):          return "바람이 부는 쉬원한 봄날"

        case (.summer, .clear):          return "쨍쨍한 여름날"
        case (.summer, .mostlyCloudy):   return "구름이 가득한 여름날"
        case (.summer, .cloudy):         return "눅눅하고 흐린 여름날"
        case (.summer, .rainy):          return "장맛비 내리는 여름날"
        case (.summer, .windy):          return "바람 불어도 뜨거운 여름날"

        case (.autumn, .clear):          return "맑고 선선한 가을날"
        case (.autumn, .mostlyCloudy):   return "구름 낀 가을날"
        case (.autumn, .cloudy):         return "쓸쓸하고 흐린 가을날"
        case (.autumn, .rainy):          return "추적추적 가을비 내리는 날"
        case (.autumn, .windy):          return "선선한 가을바람 부는 날"

        case (.winter, .clear):          return "쌀쌀한 겨울 맑은 날"
        case (.winter, .mostlyCloudy):   return "한겨울, 구름 많은 날"
        case (.winter, .cloudy):         return "흐리고 추운 겨울날"
        case (.winter, .rainy):          return "겨울비 내리는 날"
        case (.winter, .windy):          return "매서운 겨울바람 부는 날"
        case(.winter, .snowy):           return "눈 내리는 겨울날"

        default:
            return "오늘의 날씨"
        }
    }
}

// MARK: - 추천 장소
struct LocationTag: Identifiable, Hashable {
    enum Kind: Equatable { case nearby, category }
    let id: Int64
    let name: String
    let kind: Kind

    static let nearby = LocationTag(id: -1, name: "내주변", kind: .nearby)
}

// MARK: - Cards & Detail
struct CurationCard: Identifiable, Equatable {
    let id: Int64
    let title: String
    let thumbnailURL: URL?
}

struct CurationDetailImage: Identifiable, Equatable {
    let id: Int // imgOrder
    let url: URL?
}

struct CurationDetail: Equatable {
    let id: Int64
    let title: String
    let images: [CurationDetailImage]

    /// 편의: URL 배열만 필요할 때 사용
    var imageURLs: [URL] { images.compactMap { $0.url } }
}

// MARK: - Composite models (첫 화면 구성을 한 번에 보유)
struct CurationFeed: Equatable {
    let locationId: Int64
    let locationName: String
    let header: WeatherHeaderText
    let cards: [CurationCard]
    let tone: SemanticColor  // headerText.leading & 장소 칩(원) 테두리에 공용으로 사용
}

// MARK: - 매핑 (DTO → Domain)
enum CurationMapper {
    // 공통: season/weather → 헤더 문구
    private static func makeHeader(seasonString: String, weatherString: String) -> WeatherHeaderText {
        let season = Season(server: seasonString)
        let weather = SkyWeather(server: weatherString)
        let leading = WeatherPhrase.leading(season: season, weather: weather)
        return WeatherHeaderText(leading: leading)
    }

    /// /curation/location/{locationId} 또는 /curation/curationCategory/{id}
    /// 두 API 모두 동일 스키마를 사용하므로 동일 변환 사용
    static func toFeed(from dto: ApiResponseCurationByLocationResponseDto) -> CurationFeed {
        let season = Season(server: dto.data.season)
        let weather = SkyWeather(server: dto.data.weather)
        let header = makeHeader(seasonString: dto.data.season, weatherString: dto.data.weather)
        let cards: [CurationCard] = dto.data.curations.map { c in
            CurationCard(
                id: c.curationId,
                title: c.curationTitle,
                thumbnailURL: URL(string: c.backgroundImgUrl) //카드 썸네일 URL
            )
        }
        return CurationFeed(
            locationId: dto.data.locationId,
            locationName: dto.data.locationName,
            header: header,
            cards: cards,
            tone: WeatherTone.tone(for: season, weather: weather)
        )
    }

    /// 카테고리 목록 → 태그들 (고정 칩 + 서버 칩 카테고리 ID는  ViewModel에서 연결)
    static func toTags(from dto: ApiResponseListCurationCategoryResponseDto) -> [LocationTag] {
        dto.data.map { LocationTag(id: $0.curationCategoryId, name: $0.locationName, kind: .category) }
    }

    /// /curation/{curationId} 상세
    static func toDetail(from dto: ApiResponseCurationByCurationIdResponseDto) -> CurationDetail {
        let images: [CurationDetailImage] = dto.data.imgs
            .sorted { $0.imgOrder < $1.imgOrder }
            .map { CurationDetailImage(id: $0.imgOrder, url: URL(string: $0.imgUrl)) }
        return CurationDetail(id: dto.data.curationId, title: dto.data.curationTitle, images: images)
    }
}

// MARK: - View seeds (초기값/플레이스홀더)
extension WeatherHeaderText {
    static let placeholder = WeatherHeaderText(leading: "오늘의 날씨")
}

extension CurationFeed {
    static let empty = CurationFeed(locationId: 0, locationName: "", header: .placeholder, cards: [], tone: .springClear)
}
