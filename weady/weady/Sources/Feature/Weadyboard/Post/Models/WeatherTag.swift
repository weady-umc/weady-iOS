//
//  WeatherTag.swift
//  weady
//
//  Created by 엄민서 on 7/31/25.
//

enum WeatherTag: Int {
    case sunny        = 1  // 맑은 날
    case cloudy       = 2  // 구름 많은 날
    case rainy        = 3  // 비 오는 날
    case partlycloudy = 4  // 흐린 날
    case snowy        = 5  // 눈 오는 날
    case windy        = 6  // 바람 많은 날

    static func imageName(for id: Int) -> String {
        switch WeatherTag(rawValue: id) {
        case .sunny:        return "filter_sunny"
        case .cloudy:       return "filter_cloudy"
        case .rainy:        return "filter_rainy"
        case .partlycloudy: return "filter_partlycloudy"
        case .snowy:        return "filter_snowy"
        case .windy:        return "filter_windy"
        case .none:         return "filter_sunny"
        }
    }

    static func label(for id: Int) -> String {
        switch WeatherTag(rawValue: id) {
        case .sunny:        return "맑은 날"
        case .cloudy:       return "구름 많은 날"
        case .rainy:        return "비 오는 날"
        case .partlycloudy: return "흐린 날"
        case .snowy:        return "눈 오는 날"
        case .windy:        return "바람 많은 날"
        case .none:         return "알 수 없음"
        }
    }
}

//enum StyleTag: Int, CaseIterable {
//    case style1 = 1
//    case style2 = 2
//    case style3 = 3
//    case style4 = 4
//    case style5 = 5
//    case style6 = 6
//    case style7 = 7
//
//    var name: String {
//        switch self {
//        case .style1: return "999HUMANITY"
//        case .style2: return "UNIQLO"
//        case .style3: return "On Running"
//        case .style4: return "ADER"
//        case .style5: return "Mardi Mercredi"
//        case .style6: return "Nike"
//        case .style7: return "New Balance"
//        }
//    }
//}
