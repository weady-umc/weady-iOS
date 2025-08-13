//
//  TagEndpoints.swift
//  weady
//
//  Created by 김영택 on 8/2/25.
//

import Foundation
import Moya

public enum TagsEndpoints: TargetType {
    case clothesStyleCategories(token: String)

    public var baseURL: URL { URL(string: "https://weadyapi.pro")! }
    public var path: String {
        switch self {
        case .clothesStyleCategories: return "/api/v1/tags/clothes-style-categories"
        }
    }
    public var method: Moya.Method { .get }
    public var task: Task { .requestPlain }   
    public var headers: [String : String]? {
        switch self {
        case .clothesStyleCategories(let token):
            return [
                "Authorization": "Bearer \(token)",
                "Accept": "application/json"
            ]
        }
    }
    public var sampleData: Data { Data() }
}
