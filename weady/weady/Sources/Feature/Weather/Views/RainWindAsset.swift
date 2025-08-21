//
//  RainWindAsset.swift
//  weady
//
//  Created by Yoonseo on 8/17/25.
//

import Foundation
import SwiftUI

// MARK: - 강수 단계(0,25,50,75,100)로 버킷팅
// 0-10 -> 0, 10-35 -> 25, 35-60 -> 50, 60-85 -> 75, 85-100 -> 100
enum RainLevel: Int {
    case r0 = 0, r25 = 25, r50 = 50, r75 = 75, r100 = 100

    init(probability p: Int) {
        let p = max(0, min(100, p))
        switch p {
        case 0..<10:   self = .r0
        case 10..<35:  self = .r25
        case 35..<60:  self = .r50
        case 60..<85:  self = .r75
        default:       self = .r100
        }
    }

    var imageName: String { "rainIcon\(rawValue)" } 
}


// MARK: - 풍향 8방위
// 8방위 매핑 (이미 있다면 생략)
enum WindDirection: String {
    case N, NE, E, SE, S, SW, W, NW
    init(label: String) {
        let u = label.uppercased()
        let ko: [String:String] = ["북":"N","북동":"NE","동":"E","남동":"SE","남":"S","남서":"SW","서":"W","북서":"NW"]
        self = WindDirection(rawValue: ko[u] ?? u) ?? .N
    }
    var imageName: String { "windIcon\(rawValue)" } // 에셋 규칙에 맞게
}

