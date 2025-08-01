/*
import Foundation
import Moya
import KeychainSwift

enum TagEndpoints {
    case getWeatherTags
    case getTemperatureTags
    case getSeasonTags
    case getClothesStyleCategories
}

extension TagEndpoints: TargetType {
    
    public var baseURL: URL {
        guard let url = URL(string: API.communityURL) else { //TODO: - 실제 API 주소로 교체
            fatalError("잘못된 URL")
        }
        return url
    }

    var path: String {
        switch self {
        case .getWeatherTags:
            return "/api/v1/tags/weather-tags"
        case .getTemperatureTags:
            return "/api/v1/tags/temperature-tags"
        case .getSeasonTags:
            return "/api/v1/tags/season-tags"
        case .getClothesStyleCategories:
            return "/api/v1/tags/clothes-style-categories"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var task: Task {
        return .requestPlain
    }

    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }

    var sampleData: Data {
        return Data()
    }
}
*/
