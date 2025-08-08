//
//  StyleOption.swift
//  weady
//
//  Created by 김영택 on 8/1/25.
//

import Foundation

enum StyleOption: String, CaseIterable, Identifiable {
    case 캐주얼, 미니멀, 클래식, 러블리, 모던, 스트릿
    case 엘레강스, 프레피, 레트로, 시크, 애슬레저, 빈티지
    case 내추럴, 포멀, 기타

    var id: String { rawValue }
}
