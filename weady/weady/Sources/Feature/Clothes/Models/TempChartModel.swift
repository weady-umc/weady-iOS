//
//  TempChartModel.swift
//  weady
//
//  Created by 김영택 on 8/9/25.
//

import Foundation

struct TempChartModel: Identifiable {
    let id: UUID
    let date: Date
    let temp: Int
    let iconName: String?

    init(id: UUID = UUID(), date: Date, temp: Int, iconName: String? = nil) {
        self.id = id
        self.date = date
        self.temp = temp
        self.iconName = iconName
    }

    /// 체감온도를 5개 밴드 범위로 표현 (참고용)
    var range: (min: Int, max: Int) {
        switch temp {
        case 15...16: return (15, 16)
        case 17...22: return (17, 22)
        case 23...26: return (23, 26)
        case 27...30: return (27, 30)
        case 31...35: return (31, 35)
        default:      return (temp, temp)
        }
    }
}
