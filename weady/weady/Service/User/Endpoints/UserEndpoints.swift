import Foundation
import Moya

enum UserEndpoints {
    case updateProfile(data: EditProfileRequestDTO)
    case getMyPage(year: Int, month: Int)
    case getMyPageBoard(date: String, isPublic: Bool)
}

extension UserEndpoints: TargetType {
    var baseURL: URL { URL(string: "https://weadyapi.pro/api/v1")! }
    
    var path: String {
        switch self {
        case .updateProfile:
            return "/users/profile"
        case .getMyPage:
            return "/users/my-page"
        case .getMyPageBoard:
            return "/users/my-page/board"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .updateProfile:
            return .patch
        case .getMyPage, .getMyPageBoard:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .updateProfile(let data):
            return .requestJSONEncodable(data)
        case .getMyPage(let year, let month):
            return .requestParameters(
                parameters: ["year": year, "month": month],
                encoding: URLEncoding.queryString
            )
        case .getMyPageBoard(let date, let isPublic):
            return .requestParameters(
                parameters: ["date": date, "isPublic": isPublic],
                encoding: URLEncoding.queryString
            )
        }
    }
    
    var headers: [String : String]? {
        var header: [String: String] = ["Content-Type": "application/json"]
        if let token = AuthManager.shared.getAccessToken() {
            header["Authorization"] = "Bearer \(token)"
        }
        return header
    }
}
