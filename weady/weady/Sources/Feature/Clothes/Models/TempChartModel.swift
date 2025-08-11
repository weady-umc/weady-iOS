//
//  TempChartModel.swift
//  weady
//
//  Created by 김영택 on 8/9/25.
//

import Foundation

struct TempChartModel: Identifiable {
    let id = UUID()
    let date: Date
    let temp: Int

    /// 체감온도에 맞는 구간(min…max)을 Int 타입으로 반환
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

    /// 막대의 오른쪽 x값 (1시간 뒤)
    var endDate: Date {
        Calendar.current.date(byAdding: .hour, value: 1, to: date)!
    }
}
