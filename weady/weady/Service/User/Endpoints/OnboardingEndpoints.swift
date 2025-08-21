//
//  OnboardingEndpoints.swift
//  weady
//
//  Created by 김영택 on 2025/08/13
//

import Foundation
import Moya

public enum OnboardingEndpoints: TargetType {
    case submit(token: String, body: OnboardingRequestDTO)

    public var baseURL: URL { URL(string: "https://weadyapi.pro")! }
    public var path: String { "/api/v1/users/onboarding" }
    public var method: Moya.Method { .post }
    public var sampleData: Data { Data() }

    public var task: Task {
        switch self {
        case .submit(_, let body):
            return .requestJSONEncodable(body)
        }
    }

    public var headers: [String : String]? {
        switch self {
        case .submit(let token, _):
            return [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json",
                "Accept": "application/json"
            ]
        }
    }
}
