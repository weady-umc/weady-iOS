//
//  TemperatureChartView.swift
//  weady
//
//  Created by 김영택 on 8/8/25.
//

import SwiftUI

struct TemperatureChartView: View {
    @StateObject private var vm = TempChartViewModel()
    private let injectedItems: [TempChartModel]?
    private let baseDate: Date
    private let labelColor: Color

    // 기본 API 호출용
    init(baseDate: Date = Date(), labelColor: Color = .appwhite100) {
        self.baseDate = baseDate
        self.labelColor = labelColor
        self.injectedItems = nil
    }

    // 외부 ChartItem으로 초기화 (누락 시간 8..21 보정 포함)
    init(chartItems: [ChartItem], baseDate: Date = Date(), labelColor: Color = .appwhite100) {
        self.baseDate = baseDate
        self.labelColor = labelColor
        self.injectedItems = TemperatureChartView.normalize(chartItems, baseDate: baseDate)
    }

    // 목업 데이터로 초기화
    init(mock: Bool, baseDate: Date = Date(), labelColor: Color = .appwhite100) {
        self.baseDate = baseDate
        self.labelColor = labelColor
        if mock {
            self.injectedItems = TemperatureChartView.makeMockItems(baseDate: baseDate)
        } else {
            self.injectedItems = nil
        }
    }

    var body: some View {
        let models = injectedItems ?? vm.items
        return RangeBarChartView(items: models, baseDate: baseDate, labelColor: labelColor)
            // 크기는 부모에서 .frame(width:height:)로 제어
            .onAppear {
                if injectedItems == nil {
                    vm.fetchHourlyTemps(lat: 37.5665, lon: 126.9780, apiKey: "YOUR_API_KEY")
                }
            }
    }
}

extension TemperatureChartView {
    /// 8..21 모든 시간을 채우도록 보정 (결측 시 직전 값 유지), 아이콘도 함께 전달
    static func normalize(_ chartItems: [ChartItem], baseDate: Date) -> [TempChartModel] {
        let byHour = Dictionary(uniqueKeysWithValues: chartItems.map { ($0.time, $0) })
        var lastTemp: Int = 20
        let cal = Calendar.current
        return (8...21).map { h in
            let temp = byHour[h].map { Int($0.feelTmp.rounded()) } ?? lastTemp
            let icon = byHour[h]?.clothing.imageUrl
            lastTemp = temp
            let date = cal.date(bySettingHour: h, minute: 0, second: 0, of: baseDate)!
            return TempChartModel(date: date, temp: temp, iconName: icon)
        }
    }

    /// 8시부터 21시까지 샘플 데이터 생성 (14개)
    static func makeMockItems(baseDate: Date) -> [TempChartModel] {
        let cal = Calendar.current
        let start = cal.date(bySettingHour: 8, minute: 0, second: 0, of: baseDate)!
        let temps: [Int] = [25,25,25,25,26,27,27,27,28,25,25,25,17,17]
        return temps.enumerated().map { idx, t in
            let date = cal.date(byAdding: .hour, value: idx, to: start)!
            return TempChartModel(date: date, temp: t, iconName: "tshirt_icon")
        }
    }
}

// TemperatureChartView_Previews
struct TemperatureChartView_Previews: PreviewProvider {
    static var previews: some View {
        TemperatureChartView(mock: true, baseDate: Date())
            .frame(width: 293, height: 120)
            .padding()
            .background(Color.blue.opacity(0.1))
            .previewLayout(.sizeThatFits)
    }
}
