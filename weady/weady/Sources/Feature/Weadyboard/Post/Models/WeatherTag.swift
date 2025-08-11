//
//  WeatherTag.swift
//  weady
//
//  Created by 엄민서 on 7/31/25.
//

enum WeatherTag: Int {
    case sunny = 0, cloudy, rainy, snowy, partlyCloudy, windy

    static func iconName(for id: Int) -> String {
        switch id {
        case 0: return "filter_sunny"
        case 1: return "filter_cloudy"
        case 2: return "filter_rainy"
        case 3: return "filter_snowy"
        case 4: return "filter_partlycloudy"
        case 5: return "filter_windy"
        default: return ""
        }
    }

    static func label(for id: Int) -> String {
        switch id {
        case 0: return "맑음"
        case 1: return "구름 많음"
        case 2: return "비 오는 날"
        case 3: return "눈 오는 날"
        case 4: return "흐린 날"
        case 5: return "바람 많은 날"
        default: return "알 수 없음"
        }
    }
    
    static func imageName(for id: Int) -> String {
            switch id {
            case 0: return "filter_sunny"
            case 1: return "filter_cloudy"
            case 2: return "filter_rainy"
            case 3: return "filter_snowy"
            case 4: return "filter_partlycloudy"
            case 5: return "filter_windy"
            default: return ""
            }
        }
}

enum StyleTag: Int, CaseIterable {
    case style1 = 1
    case style2 = 2
    case style3 = 3
    case style4 = 4
    case style5 = 5
    case style6 = 6
    case style7 = 7

    var name: String {
        switch self {
        case .style1: return "999HUMANITY"
        case .style2: return "UNIQLO"
        case .style3: return "On Running"
        case .style4: return "ADER"
        case .style5: return "Mardi Mercredi"
        case .style6: return "Nike"
        case .style7: return "New Balance"
        }
    }
}
